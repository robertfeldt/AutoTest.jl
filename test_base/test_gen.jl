facts("Gen building blocks and utils") do

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

  context("SeqGen") do

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

  context("QuickCheck's base generators") do

    context("gen Int64") do
      for(i in 1:NumTestReps)
        v = gen(Int64, 10)
        @fact v <= 10 => true
        @fact v >= -10 => true
      end
    end

    context("gen Float64") do
      for(i in 1:NumTestReps)
        v = gen(Float64, 0.5)
        @fact v <= 0.5 => true
        @fact v >= -0.5 => true
      end
    end

    context("gen String") do
      for(i in 1:NumTestReps)
        v = gen(typeof("a"), 4)
        @fact typeof(v) == ASCIIString => true
        @fact length(v) == 4 => true
      end
    end

    context("gen Array{Float64,2}") do
      for(i in 1:NumTestReps)
        v = gen(Array{Float64,2}, 7)
        @fact typeof(v) == Array{Float64,2} => true
        @fact size(v,1) <= 7 => true
        @fact size(v,2) <= 7 => true
      end
    end

  end

#  context("DataGen") do
#    dg = DataGen(Int64)
#    for(i in 1:NumTestReps)
#      v = gen(dg, 42)
#      @fact v <= 10 => true
#      @fact v >= -10 => true
#    end
#  end
#
#  context("SizedGen") do
#    #sg = SizedGen(5, )
#  end

end