import AutoTest.report_failed_comparison

facts("Reporting failed comparison") do

  @fact report_failed_comparison(:(1==2), 1, 2) => "Expected 1 == 2!!!\n"

  @fact report_failed_comparison(:(f(1)==2), 1, 2) => "Expected f(1) == 2\n     but f(1) was 1\n"

  @fact report_failed_comparison(:(1==f(2)), 1, 2) => "Expected 1 == f(2)\n     but f(2) was 2\n"

  @fact report_failed_comparison(:(f(1)==f(2)), 1, 2) => "Expected f(1) == f(2)\n     but f(1) was 1\n      and f(2) was 2\n"

end
