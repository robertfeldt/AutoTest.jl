# IMHO, the problem with Patrick O'leary's generators in QuickCheck.jl
# is that it is not easy to see how it can be extended so that multiple
# generators can be specified for one and the same (Julia) type. As an example
# with the QuickCheck.jl generators we can generate integers in [-2, 2]
# with a call to gen(Int64, 2) but if we want to generate integers in [-3, 2]
# it is not so clear how we can extend it. Thus, in this design we make
# a difference between the type of the data being generated and the generator
# itself; there can be many generators for the same type of data, rather than
# only one. A generator is essentially a specific probability distribution
# over the values that can be described with a certain (Julia) type.
# 
# When testing we would like to specify only the type of the data, and we
# would like our testing tool help us explore which distribution over that
# type is both
#  - Allowed (this helps us refine our understanding of the code and spec)
#  - Good (in the sense that it helps us achieve a testing goal, for example, coverage of the code, or testing new distributions of data to explore the code, spec and types involved)
# For testing we actually want such specifications to be "loose". If our specs
# are "too tight" we will actually not test the whole functionality and might
# not find all bugs.
# 
# Examples:
# 1. Specifying a new generator that generates integers on both sides and on
#  a "boundary", here specified with an integer.
#
#  type BoundarySigned <: Gen{Signed}
#    boundary::Signed
#    BoundarySigned(boundary) = new(boundary)
#  end
#  gen(g::BoundarySigned) = begin 
#    b = g.boundary
#    sample( [b-2, b-1, b, b+1, b+2] )
#  end 
#  add_gen(Signed)
# 
using Distributions

abstract Gen{T}

# A composite generator has other generators below it that it might use
# when generating a value. Default is to not be a composite.
iscomposite(g) = false

# Randomly return one of the arguments.
randarg(args...) = args[rand(1:length(args))]

type SeqGen <: Gen{Any}
  seq
  SeqGen(args...) = new(args)
end

gen(g::SeqGen) = begin
  vforg = randarg(g.seq...)
  if(typeof(vforg) == Function)
    vforg()
  elseif (typeof(vforg) == Gen)
    gen(vforg)
  else
    vforg
  end
end

# Randomly generate a sign value.
randsign() = randarg(-1, 1)

# Here is an example of how one can generate test data on a given boundary b.
type BoundarySigned <: Gen{Signed}
  b::Signed
  d
  subgen
  BoundarySigned(b = 0, distr = Levy()) = begin
    sg = SeqGen(b-2, b-1, b, b+1, b+2, 
      () -> b + randsign() * oftype(g.b, floor(rand(g.d))))
    new(b, distr, sg)
  end
end

gen(g) = gen(g.subgen)


# Inspirational code from QuickCheck.jl:
# Default generators for primitive types
#gen{T<:Unsigned}(::Type{T}, size) = convert(T, rand(1:size))
#gen{T<:Signed}(::Type{T}, size) = convert(T, rand(-size:size))
#gen{T<:FloatingPoint}(::Type{T}, size) = convert(T, (rand()-0.5).*size)
# This won't generate interesting UTF-8, but doing that is a Hard Problem
#gen{T<:String}(::Type{T}, size) = convert(T, randstring(size))

# Generator for array's
#function gen{T,n}(::Type{Array{T,n}}, size)
#  dims = [rand(1:size) for i in 1:n]
#  reshape([generator(T, size) for x in 1:prod(dims)], dims...)
#end
