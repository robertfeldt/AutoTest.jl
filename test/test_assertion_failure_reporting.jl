import AutoTest.assertion_failure_report

test("Assertion failure reporting") do

  test("Equality comparison with simple data types") do

    @t assertion_failure_report(:(1 == 2)) == "Expected 1 to BE == to 2, but it WAS NOT"

    @t assertion_failure_report(:(1 != 1)) == "Expected 1 to NOT BE == to 1, but it WAS"

    @t assertion_failure_report(:(1 < 0)) == "Expected 1 to BE < than 0, but it WAS NOT"

    @t assertion_failure_report(:("1" == "2")) == "Expected \"1\" to BE == to \"2\", but it WAS NOT"

    @t assertion_failure_report(:("1" == 1)) == "Expected \"1\" to BE == to 1, but it WAS NOT"

    @t assertion_failure_report(:("1" != "1")) == "Expected \"1\" to NOT BE == to \"1\", but it WAS"

  end

  add_func_with_long_name(x, y) = x + y

  test("Comparisons with more complex expressions on the left") do

    @t assertion_failure_report(:(add_func_with_long_name(1, 1) == 3)) == "Expected add_func_with_long_name(1,1) to BE == to 3, but it WAS NOT"

    @t assertion_failure_report(:(add_func_with_long_name(1, 1) != 2)) == "Expected add_func_with_long_name(1,1) to NOT BE == to 2, but it WAS"

  end

end