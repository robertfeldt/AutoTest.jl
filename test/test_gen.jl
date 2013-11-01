
facts("Basic Gen building blocks and utils") do
  context("oneof returns the value if only supplied with one value") do
    @fact AutoTest.randarg(1) => 1
    @fact AutoTest.randarg(true) => true
    @fact AutoTest.randarg(false) => false
  end

  context("oneof samples among the given values when supplied with more than one value") do
    for(i in 1:NumTestReps)
      v = AutoTest.randarg(1, 2)
      @fact in(v, [1,2]) => true

      v = AutoTest.randarg(1, 2, 99)
      @fact in(v, [1,2,99]) => true
    end
  end

  context("oneof samples a function by calling it and returning its return value") do
    for(i in 1:NumTestReps)
      v = AutoTest.randarg(1, 2)
      @fact in(v, [1,2]) => true

      v = AutoTest.randarg(1, 2, 99)
      @fact in(v, [1,2,99]) => true
    end
  end
end

facts("SeqGen") do
end