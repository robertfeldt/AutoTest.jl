import AutoTest.report_failed_comparison

test("Reporting failed comparison") do

  @t report_failed_comparison(:(1==2), 1, 2) == "Expected 1 == 2!!!\n"

  @t report_failed_comparison(:(f(1)==2), 1, 2) == "Expected f(1) == 2\n     but f(1) is 1\n"

  @t report_failed_comparison(:(1==f(2)), 1, 2) == "Expected 1 == f(2)\n     but f(2) is 2\n"

  @t report_failed_comparison(:(f(1)==f(2)), 1, 2) == "Expected f(1) == f(2)\n     but f(1) is 1\n      and f(2) is 2\n"

end
