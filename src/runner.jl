# There is always a set of tags that determines which tests are executed.
# By adding/deleting tags a user can have control over which tests to run.
CurrentRunTags = Set(:normal)

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
  num_pass::Int64
  num_fail::Int64
  num_error::Int64  
  next_column::Int64 # Next column to print progress in.
  start_time
  tags

  TestSuiteExecution(desc, level = 0, tags = Set(:normal)) = begin
    new(level, desc, Any[], 0, 0, 0, level, time(), tags)
  end
end

CurrentExec = TopExec = TestSuiteExecution("<top>")
VerbosityLevel = 1

set_verbosity!(newLevel) = VerbosityLevel = newLevel

# Print at verbosity level.
printav(level, args...) = begin
  if level < VerbosityLevel
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

# Traverse the tree of tests and callback on each one.
each_test(callback, tse = AutoTest.CurrentExec) = begin
  callback(tse)
  for(t in tse.children)
    each_test(callback, t)
  end
end

# We only count tests that has been run and that contains at least one
# assert/check, the other ones are used for hierarchy/organisation/reporting.
num_tests(s::TestSuiteExecution = AutoTest.CurrentExec) = begin
  count = 0
  count_if_has_checks(tse) = (num_checks(tse) > 0) ? (count += 1) : 0
  each_test(count_if_has_checks)
  count - 1 # Subtract one since we should not include <top>, which we created
end

set_current_execution!(body, tse::TestSuiteExecution) = begin
  global CurrentExec
  old, CurrentExec = CurrentExec, tse
  body()
  CurrentExec = old
end

# True iff the given TSE should be executed.
should_run(tse) = length(intersect(tse.tags, AutoTest.CurrentRunTags)) > 0

# Note that the reference to the global var CurrentExec makes this 
# hard/unparallelizable??! Investigate better approaches.
function test(body, description = "", tags...)
  old_tse = AutoTest.CurrentExec
  tags = Set(tags...)
  push!(tags, :normal) # All tests are always tagged :normal
  new_tse = TestSuiteExecution(description, old_tse.level+1, tags)
  push!(old_tse.children, new_tse)
  leading = reps("-", old_tse.level)
  printav(2, "\n", leading, description, "\n", reps(" ", old_tse.level))
  if should_run(new_tse)
    set_current_execution!(new_tse) do
      body()
    end
  end
end

test_suite_report(tse = AutoTest.CurrentExec) = begin
  (num_tests(), num_pass(tse), num_fail(tse), num_error(tse), time() - tse.start_time)
end

function report_assertions(tse = AutoTest.CurrentExec)
  nt, np, nf, ne, t = test_suite_report(tse)
  printav(1, "\n\nFinished in ", @sprintf("%.3f seconds", t))
  printav(1, "\n", nt, " tests, ", np+nf+ne, " asserts, ", 
    np, " passed, ", nf, " failed, ", ne, " errors.\n")
end

function reps(str, len)
  join([str for i in 1:len], "")
end

function mark_progress(char)
  if CurrentExec.next_column == 78
    CurrentExec.next_column = 0
    printav(2, reps(" ", CurrentExec.level))
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
    mark_progress("F")
  elseif outcome == :error
    AutoTest.CurrentExec.num_error += 1
    mark_progress("E")
  end
end

# Macro that checks if something is true (a pass), false (a fail) or if an
# error/exception (an error) was thrown.
macro t(ex)
  quote
    try
      res = $(esc(ex))
      if res
        log_outcome(:pass)
        nothing
      else
        log_outcome(:fail)
        sp = reps(" ", AutoTest.CurrentExec.level-1)
        printav(1, "\n", sp, "Assertion failed: ", $(string(ex)), "\n", sp)
      end
    catch e
      log_outcome(:error, e)
    end
  end
end
