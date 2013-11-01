include("helper.jl")

NumTestReps = 100

# The base tests are not allowed to use any AutoTest features for the testing;
# they should test the basic AutoTest features that we build the rest on.
using FactCheck

my_tests = [

  "test_gen.jl",
  "test_runner.jl",

]

tic()
for t in my_tests
  include(t)
end
println("Finished in ", @sprintf("%.3f", toq()), " seconds\n")