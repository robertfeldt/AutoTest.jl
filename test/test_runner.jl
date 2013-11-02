facts("TestSuiteExecution") do

  # Ensure nothing is printed on console now when testing
  AutoTest.set_verbosity!(0)

  top = AutoTest.CurrentExec

  @fact AutoTest.num_pass() => 0
  @fact AutoTest.num_fail() => 0
  @fact AutoTest.num_error() => 0

  ta = test("A") do

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

    tb = test("B") do

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

      @t begin
        throw(ArgumentError("dummy"))
      end

      @fact AutoTest.num_pass() => 1
      @fact AutoTest.num_fail() => 1
      @fact AutoTest.num_error() => 1

      @throws begin
        throw(ArgumentError("dummy"))
      end

      @fact AutoTest.num_pass() => 2
      @fact AutoTest.num_fail() => 1
      @fact AutoTest.num_error() => 1

    end

    @fact tb.tags == Set() => true

  end

  @fact ta.tags == Set() => true

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()

  @fact npass => 4
  @fact nfail => 2
  @fact nerr => 1
  @fact ntest => 2

  AutoTest.run_only_tags!(:test, :quick)
  tc = test("C", :test) do
    @t true
    @t false
  end

  @fact tc.tags == Set(:test) => true

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()
  @fact npass => 5
  @fact nfail => 3
  @fact nerr => 1
  @fact ntest => 3

  # This one should not be executed...
  td = test("D", :slow) do
    @t true
    @t false
  end

  @fact td.tags == Set(:slow) => true

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()
  @fact npass => 5
  @fact nfail => 3
  @fact nerr => 1
  @fact ntest => 3

  # But if we add also the slow tag the tests tagged with slow are also executed.
  AutoTest.run_only_tags!(:test, :quick, :slow)
  te = test("E", :slow) do
    @t true
    @t false
  end

  @fact td.tags == Set(:slow) => true

  ntest, npass, nfail, nerr = AutoTest.test_suite_report()
  @fact npass => 6
  @fact nfail => 4
  @fact nerr => 1
  @fact ntest => 4

end
