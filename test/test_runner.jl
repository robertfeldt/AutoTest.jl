facts("TestSuiteExecution") do

  # Ensure nothing is printed on console now when testing
  AutoTest.set_verbosity!(0)

  top = AutoTest.CurrentExec

  @fact AutoTest.num_pass() => 0
  @fact AutoTest.num_fail() => 0
  @fact AutoTest.num_error() => 0

  test("A") do

    @fact top != AutoTest.CurrentExec => true

    @fact AutoTest.num_pass() => 0
    @fact AutoTest.num_fail() => 0
    @fact AutoTest.num_error() => 0

    @t true

    @fact AutoTest.num_pass() => 1
    @fact AutoTest.num_fail() => 0
    @fact AutoTest.num_error() => 0

    a = 1
    @t a == 1

    @fact AutoTest.num_pass() => 2
    @fact AutoTest.num_fail() => 0
    @fact AutoTest.num_error() => 0

    @t a == 2

    @fact AutoTest.num_pass() => 2
    @fact AutoTest.num_fail() => 1
    @fact AutoTest.num_error() => 0

    test("B") do

      @fact AutoTest.num_pass() => 0
      @fact AutoTest.num_fail() => 0
      @fact AutoTest.num_error() => 0

      @t false

      @fact AutoTest.num_pass() => 0
      @fact AutoTest.num_fail() => 1
      @fact AutoTest.num_error() => 0

      @t true

      @fact AutoTest.num_pass() => 1
      @fact AutoTest.num_fail() => 1
      @fact AutoTest.num_error() => 0

    end

  end

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()

  @fact npass => 3
  @fact nfail => 2
  @fact nerr => 0
  @fact ntest => 2

  AutoTest.run_only_tags!(:normal, :quick)
  test("C", :normal) do
    @t true
    @t false
  end

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()

  @fact npass => 4
  @fact nfail => 3
  @fact nerr => 0
  @fact ntest => 3

end
