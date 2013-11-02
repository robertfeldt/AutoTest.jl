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

  r = AutoTest.test_suite_report()

  @fact r["np"] => 4
  @fact r["nf"] => 2
  @fact r["ne"] => 1
  @fact r["nt"] => 2

  AutoTest.run_only_tags!(:test, :quick)
  tc = test("C", :test) do
    @t true
    @t false
  end

  @fact tc.tags == Set(:test) => true

  r = AutoTest.test_suite_report()
  @fact r["np"] => 5
  @fact r["nf"] => 3
  @fact r["ne"] => 1
  @fact r["nt"] => 3

  # This one should not be executed...
  td = test("D", :slow) do
    @t true
    @t false
  end

  @fact td.tags == Set(:slow) => true

  r = AutoTest.test_suite_report()
  @fact r["np"] => 5
  @fact r["nf"] => 3
  @fact r["ne"] => 1
  @fact r["nt"] => 3

  # But if we add also the slow tag the tests tagged with slow are also executed.
  AutoTest.run_only_tags!(:test, :quick, :slow)
  te = test("E", :slow) do
    @t true
    @t false
  end

  @fact td.tags == Set(:slow) => true

  r = AutoTest.test_suite_report()
  @fact r["np"] => 6
  @fact r["nf"] => 4
  @fact r["ne"] => 1
  @fact r["nt"] => 4

end
