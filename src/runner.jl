# There is always a set of tags that determines which tests are executed.
# By adding/deleting tags a user can have control over which tests to run.
CurrentRunTags = Set(:test)

# Set which test tags should currently be included when running tests.
run_only_tags!(tags...) = begin
  global CurrentRunTags
  CurrentRunTags = Set(tags...)
end

# A test suite is a related set of test cases / checks. A TestSuiteExecution 
# collects information about test execution for such a suite together. It supports
# hierarchies of executions so that test executions can be nested within
# each other but still reported on collectively. The general design used is
# that when everything passes things are just reported on the top level; only
# when there is a failure is the hierarchy used to give more information.
type TestSuiteExecution
  level::Int64 # Level in the hierarchy. Is 0 at the top level and then increases by one per level.
  description::ASCIIString
  children
  body
  num_pass::Int64
  num_fail::Int64
  num_error::Int64  
  next_column::Int64 # Next column to print progress in.
  start_time
  tags

  TestSuiteExecution(desc, body::Function, level = 0, tags = Set()) = begin
    new(level, desc, Any[], body, 0, 0, 0, level, time(), tags)
  end
end

CurrentExec = TopExec = TestSuiteExecution("<top>", () -> (1))

# Execute a block of code with a new/unique CurrentExec and TopExec installed.
execute_with_new_tse(body) = begin
  global TopExec
  global CurrentExec

  # Set a new top tse that the rest will be nested inside
  CurrentExec = TopExec = TestSuiteExecution("<top>", () -> (1))

  body()

  # Set a new top exec so we don't pollute this one later.
  test_exec, TopExec = TopExec, TestSuiteExecution("<top>", () -> (1))
  CurrentExec = TopExec  

  test_exec
end

function run_tests_in_file(file; verbosity = 2)
  tse = execute_with_new_tse() do
    execute_with_verbosity(verbosity) do
      printav(4, "Loading test file ", file)
      include(file)
    end
  end

  stats = AutoTest.report(tse)

  return tse, stats
end

function run_all_tests_in_dir(testDir; verbosity = 2,
  regexpTestFiles = r"^test.*\.jl$")
  tse = execute_with_new_tse() do
    execute_with_verbosity(verbosity) do
      printav(4, "Running tests in dir: ", testDir)

      cb(filename) = begin
        printav(4, "Loading test file ", filename)
        include(filename) # When we include it all its test will be run
      end
      AutoTest.Utils.recurse_and_find_all_files_matching(cb, testDir, regexpTestFiles)
    end
  end

  stats = AutoTest.report(tse)

  return tse, stats
end

function clear_statistics_for_new_execution(tse::TestSuiteExecution)
  clear_tse(tse) = begin
    tse.num_pass = tse.num_fail = tse.num_error = 0
  end
  # Clear for the given one and all its children
  each_test(clear_tse, tse)
end

# Note that the reference to the global var CurrentExec makes this 
# hard/unparallelizable??! Investigate better approaches.
function test(body, description = "", tags...)
  old_tse = AutoTest.CurrentExec
  new_tse = TestSuiteExecution(description, body, old_tse.level+1, Set(tags...))
  push!(old_tse.children, new_tse)
  run_tests_from(new_tse)
end

VerbosityLevel = 2
set_verbosity!(newLevel) = begin
  global VerbosityLevel
  VerbosityLevel = newLevel
end

function execute_with_verbosity(block, level)
  global VerbosityLevel
  old_verbosity = VerbosityLevel
  VerbosityLevel = level
  result = block()
  VerbosityLevel = old_verbosity
  result
end

# Print at verbosity level.
printav(level, args...) = begin
  if level <= VerbosityLevel
    print(args...)
  end
end

num_pass(s) = 0
num_fail(s) = 0
num_error(s) = 0
num_pass(s::TestSuiteExecution = AutoTest.CurrentExec) = s.num_pass + sum([num_pass(c) for c in s.children])
num_fail(s::TestSuiteExecution = AutoTest.CurrentExec) = s.num_fail + sum([num_fail(c) for c in s.children])
num_error(s::TestSuiteExecution = AutoTest.CurrentExec) = s.num_error + sum([num_error(c) for c in s.children])
num_checks(s::TestSuiteExecution = AutoTest.CurrentExec) = num_pass(s) + num_fail(s) + num_error(s)
num_checks_without_recurse(tse::TestSuiteExecution) = tse.num_pass + tse.num_fail + tse.num_error

# Traverse the tree of tests and callback on each one.
each_test(callback, tse = AutoTest.CurrentExec) = begin
  callback(tse)
  for(t in tse.children)
    each_test(callback, t)
  end
end

# We only count tests that has been run and that contains at least one
# assert/check, the other ones are used for hierarchy/organisation/reporting.
num_tests(tse::TestSuiteExecution = AutoTest.CurrentExec) = begin
  count = 0
  count_if_has_checks(tse) = (num_checks_without_recurse(tse) > 0) ? (count += 1) : 0
  each_test(count_if_has_checks, tse)
  count
end

set_current_execution!(body, tse::TestSuiteExecution) = begin
  global CurrentExec
  old, CurrentExec = CurrentExec, tse
  body()
  CurrentExec = old
end

# True iff the given TSE should be executed. It should always be executed if
# it is only tagged with :test, otherwise only if it has any of the tags
# that are currently selected.
should_run(tse) = length(tse.tags) == 0 || length(intersect(tse.tags, AutoTest.CurrentRunTags)) > 0

rerun_tests_from_top() = run_tests_from(TopExec, true)

indents(tse::TestSuiteExecution) = reps(" ", max(0, tse.level-1))

run_tests_from(tse::TestSuiteExecution, clearStats = false) = begin
  if clearStats
    clear_statistics_for_new_execution(tse)
  end
  if should_run(tse)
    printav(2, "\n", indents(tse), blue(tse.description), " ")
    set_current_execution!(tse) do
      tse.body()
    end
  end
  tse
end

test_suite_report(tse = AutoTest.CurrentExec) = begin
  t = time()
  {
    "nt" => num_tests(tse), 
    "np" => num_pass(tse), 
    "nf" => num_fail(tse), 
    "ne" => num_error(tse), 
    "elt" => (t - tse.start_time),
  }
end

pl(num, word) = join([num, " ", word, ((num > 1) ? "s" : "")])

function report(tse = AutoTest.CurrentExec)
  r = test_suite_report(tse)

  printav(1, "\n\nFinished in ", @sprintf("%.3f seconds", r["elt"]), "\n")

  printav(1, "\n", 
    blue(pl(r["nt"], "test")), ", ", 
    pl(r["np"]+r["nf"]+r["ne"], "assert"), ", ",
    annotateif(r["np"] > 0, GREEN, [r["np"], " passed"]), ", ", 
    annotateif(r["nf"] > 0, REDBOLD, [r["nf"], " failed"]), ", ", 
    annotateif(r["ne"] > 0, RED, pl(r["ne"], "error")), 
    ".\n")

  r
end

function reps(str, len)
  join([str for i in 1:len], "")
end

function mark_progress(char)
  if CurrentExec.next_column == 78
    CurrentExec.next_column = 0
    printav(2, indents(CurrentExec))
  end
  printav(2, char)
  CurrentExec.next_column += 1
end

function log_outcome(outcome, error = nothing)
  if outcome == :pass
    AutoTest.CurrentExec.num_pass += 1
    mark_progress(".")
  elseif outcome == :fail
    AutoTest.CurrentExec.num_fail += 1
    mark_progress(redb("F"))
  elseif outcome == :error
    AutoTest.CurrentExec.num_error += 1
    mark_progress(red("E"))
  end
end

# Safely return an arg of an Expr or fallback to returning nothing if it is not
# an expression
safearg(e::Expr, argnum) = (argnum <= length(e.args)) ? e.args[argnum] : nothing
safearg(notexpr, argnum) = nothing
safehead(e::Expr) = e.head
safehead(notexpr) = nothing

# Macro that checks if something is true (a pass), false (a fail) or if an
# error/exception (an error) was thrown.
macro t(ex)
  quote
    #local sp = indents(AutoTest.CurrentExec) * " "
    #try
      res = $(esc(ex))
      if res
        #log_outcome(:pass)
        nothing
      else
        #log_outcome(:fail)
        #printav(1, "\n", sp, redb("Assertion failed: "), $(format(ex)), "\n")
        if $(typeof(ex)) == Expr && $(safehead(ex) == :comparison)
          #println(1)
          #printav(1, sp, " ", redb(report_failed_comparison($ex, $(esc(safearg(ex, 1))), $(esc(safearg(ex, 3))))), "\n", sp)
          repo($ex, $(esc(safearg(ex, 1))), $(esc(safearg(ex, 3))))
          #println(2)
        else
          #printav(0, "HERE WE ARE!", $(string(ex), "\n"))
        end
      end
    #catch exception
      #printav(0, "ERROR! ", string(exception), "\n")
      #log_outcome(:error, exception)
      # local sp = indents(AutoTest.CurrentExec) * " "
      #printav(1, "\n", sp, red("Error when checking assertion: "), $(format(ex)), "\n", sp, exception, "\n", sp)
    #end
  end
end

# Macro to check that exceptions are thrown. a
macro throws(ex)
  quote
    try
      res = $(esc(ex))
      if res
        log_outcome(:fail)
        sp = indents(AutoTest.CurrentExec) * " "
        printav(1, "\n", sp, redb("Assertion failed: No exception was thrown"), $(string(ex)), "\n", sp)
      end
    catch e
      log_outcome(:pass)
    end
  end
end
