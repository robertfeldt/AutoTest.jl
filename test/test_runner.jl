facts("TestSuiteExecution") do

  # Ensure nothing is printed on console now when testing
  AutoTest.set_verbosity!(0)

  top = AutoTest.CurrentExec

  @fact AutoTest.test_suite_report()[1] => 0
  @fact AutoTest.test_suite_report()[2] => 0

  suite("A") do

    @fact top != AutoTest.CurrentExec => true

    @fact AutoTest.test_suite_report()[1] => 0
    @fact AutoTest.test_suite_report()[2] => 0
    @a true
    @fact AutoTest.test_suite_report()[1] => 1
    @fact AutoTest.test_suite_report()[2] => 0

    a = 1

    @a a == 1
    @fact AutoTest.test_suite_report()[1] => 2
    @fact AutoTest.test_suite_report()[2] => 0

    @a a == 2
    @fact AutoTest.test_suite_report()[1] => 2
    @fact AutoTest.test_suite_report()[2] => 1

    suite("B") do

      @fact AutoTest.test_suite_report()[1] => 0
      @fact AutoTest.test_suite_report()[2] => 0

      @a false
      @fact AutoTest.test_suite_report()[1] => 0
      @fact AutoTest.test_suite_report()[2] => 1

      @a true
      @fact AutoTest.test_suite_report()[1] => 1
      @fact AutoTest.test_suite_report()[2] => 1

    end

  end

  r = AutoTest.test_suite_report()

  @fact r[1] => 3
  @fact r[2] => 2

end

#suite("A") do
#  suite("B") do
#    @a true
#    @a true
#    a = 1
#    @a a == 2
#    @a true
#    @a true
#    suite("C") do
#      @a true
#      k = false
#      @a k != false
#    end
#  end
#end
#
#suite("A2") do
#  @assert true
#end
#
#AutoTest.report_assertions()