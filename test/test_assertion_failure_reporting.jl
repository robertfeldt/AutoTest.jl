import AutoTest.assertion_failure_report

test("Assertion failure reporting") do

  test("Equality comparison") do

    @t assertion_failure_report(:(1 == 2)) == "Expected 1 to BE == to 2, but it WAS NOT"

    @t assertion_failure_report(:(1 != 1)) == "Expected 1 to NOT BE == to 1, but it WAS"

  end

end