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
  next_column::Int64 # Next column to print progress in.
  start_time

  TestSuiteExecution(desc, level = 0) = new(level, desc, Any[], 0, 0, level, time())
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

num_pass(x) = 0
num_fail(x) = 0
num_pass(s::TestSuiteExecution) = s.num_pass + sum([num_pass(c) for c in s.children])
num_fail(s::TestSuiteExecution) = s.num_fail + sum([num_fail(c) for c in s.children])

set_current_execution(body, tse::TestSuiteExecution) = begin
  old = AutoTest.CurrentExec
  global CurrentExec
  CurrentExec = tse
  body()
  CurrentExec = old
end

# Note that the reference to the global var CurrentExec makes this 
# hard/unparallelizable??! Investigate better approaches.
function suite(body, description = "")
  old_tse = AutoTest.CurrentExec
  new_tse = TestSuiteExecution(description, old_tse.level+1)  
  push!(old_tse.children, new_tse)
  leading = reps("-", old_tse.level)
  printav(2, "\n", leading, description, "\n", reps(" ", old_tse.level))
  set_current_execution(new_tse) do
    body()
  end
end

test_suite_report(tse = AutoTest.CurrentExec) = begin
  (num_pass(tse), num_fail(tse), time() - tse.start_time)
end

function report_assertions(tse = AutoTest.CurrentExec)
  np, nf, t = test_suite_report(tse)
  printav(1, "\n\nFinished in ", @sprintf("%.3f seconds", t))
  printav(1, "\n", np+nf, " asserts, ", np, " passed, ", nf, " failed.\n")
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

function log_outcome(outcome)
  if outcome == true
    AutoTest.CurrentExec.num_pass += 1
    mark_progress(".")
  else
    AutoTest.CurrentExec.num_fail += 1
    mark_progress("F")
  end
end

macro a(ex)
  quote
    if $(esc(ex))
      log_outcome(true)
      nothing
    else
      log_outcome(false)
      sp = reps(" ", AutoTest.CurrentExec.level-1)
      printav(1, "\n", sp, "Assertion failed: ", $(string(ex)), "\n", sp)
    end
  end
end