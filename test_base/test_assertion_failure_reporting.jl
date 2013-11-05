import AutoTest.report_failed_comparison
import AutoTest.@safeesceval
import AutoTest.@asrt

facts("Reporting failed comparison") do

    context("safeesceval") do

    @fact( @safeesceval(true) => true )
    @fact( @safeesceval(false) => false )
    @fact( @safeesceval(1) => 1 )
    @fact( @safeesceval(4.65) => 4.65 )
    @fact( @safeesceval("str") => "str" )

    a = 1
    @fact( @safeesceval(a) => 1 )
    a = 2
    @fact( @safeesceval(a) => 2 )

    b = 1
    @fact( @safeesceval(a == b) => false )
    a = 1
    @fact( @safeesceval(a == b) => true )

    i(x) = x
    @fact( @safeesceval(i(a) == i(b)) => true )

    r = @safeesceval(finkel(a) == i(b))
    @fact( typeof(r) => ErrorException )

    r = @safeesceval(i(a) == i(c))
    @fact( typeof(r) => ErrorException )

  end

  context("@asrt macro") do
    @fact( @asrt(1==1) => (:pass, nothing) )

    @fact( @asrt(true) => (:pass, nothing) )

    @fact( @asrt(1==1) => (:pass, nothing) )

    @fact( @asrt(1!=2) => (:pass, nothing) )

    @fact( @asrt(1 > 0) => (:pass, nothing) )

    @fact( @asrt(1 < 2) => (:pass, nothing) )

    @fact( @asrt(1==2) => (:fail, "Expected 1 == 2 to be true (which it is NOT!!)") )

    @fact( @asrt(1!=1) => (:fail, "Expected 1 != 1 to be true (which it is NOT!!)") )

    @fact( @asrt(1 > 3) => (:fail, "Expected 1 > 3 to be true (which it is NOT!!)") )

    @fact( @asrt(1 < 0) => (:fail, "Expected 1 < 0 to be true (which it is NOT!!)") )

    @fact( @asrt(isapprox(1.0, 2.0)) => (:fail, "Expected isapprox(1.0,2.0) to be true (which it is NOT!!)") )

    @fact( @asrt(false) => (:fail, "Expected false to be true (which it is NOT!!)") )
  end

  context("report failed comparison") do

    @fact report_failed_comparison("1 == 2", "", "") => "Expected 1 == 2 to be true (which it is NOT!!)"

    @fact report_failed_comparison("f(1) == 2", "f(1) was 1", "") => "Expected f(1) == 2\n but f(1) was 1"

    @fact report_failed_comparison("1 == f(2)", "", "f(2) was 2") => "Expected 1 == f(2)\n but f(2) was 2"

    @fact report_failed_comparison("f(1) == f(2)", "f(1) was 1", "f(2) was 2") => "Expected f(1) == f(2)\n but f(1) was 1, and\n     f(2) was 2"

  end

end
