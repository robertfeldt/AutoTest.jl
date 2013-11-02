module AutoTest

export test, @t, @throws, gen

module Utils
  include("utils/recurse_files.jl")
end

include("runner.jl")
include("gen.jl")
include("autotest_starter.jl")
#include("godel_test_gen.jl")

end