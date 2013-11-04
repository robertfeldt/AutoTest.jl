module AutoTest

export test, @t, @throws, gen

# Export function to help in assertions/checks:
export in_delta

module Utils
  include("utils/recurse_files.jl")
end

include("utils/color_print.jl")
include("runner.jl")
include("assertion_failure_reporting.jl")
include("gen.jl")
include("autotest_starter.jl")
include("assertions.jl")
#include("godel_test_gen.jl")

end