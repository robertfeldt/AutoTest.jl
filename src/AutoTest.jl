module AutoTest

export test, @t, @throws, gen

include("runner.jl")
include("gen.jl")
#include("godel_test_gen.jl")

end