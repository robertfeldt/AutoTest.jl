
facts("Basic Gen building blocks and utils") do
  context("randarg returns the value if only supplied with one value") do
    @fact AutoTest.randarg(1) => 1
    @fact AutoTest.randarg(true) => true
    @fact AutoTest.randarg(false) => false
  end

  context("randarg samples among the given values when supplied with more than one value") do
    for(i in 1:NumTestReps)
      v = AutoTest.randarg(1, 2)
      @fact in(v, [1, 2]) => true

      v = AutoTest.randarg(1, 2, 99)
      @fact in(v, [1, 2, 99]) => true
    end
  end

  context("randsign returns -1 or 1") do
    for(i in 1:NumTestReps)
      v = AutoTest.randsign()
      @fact in(v, [-1, 1]) => true
    end
  end
end

facts("SeqGen") do
  context("returns one of its values if its sequence only has values in it") do
    sg = AutoTest.SeqGen(-11, 2, -4)
    for(i in 1:NumTestReps)
      v = gen(sg)
      @fact in(v, [-11, 2, -4]) => true
    end
  end

  context("calls a function specified in its sequence") do
    sg = AutoTest.SeqGen( () -> 1 )
    @fact gen(sg) => 1
  end

  context("calls functions specified in its sequence, even if many and mixed with values") do
    sg = AutoTest.SeqGen( () -> 1, 2, () -> 3, 5 )
    for(i in 1:NumTestReps)
      v = gen(sg)
      @fact in(v, [1, 2, 3, 5]) => true
    end
  end
end