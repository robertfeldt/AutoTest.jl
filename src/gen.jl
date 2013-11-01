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

gen(g::SeqGen, size = nothing) = begin
  vforg = randarg(g.seq...)
  if(typeof(vforg) == Function)
    vforg()
  elseif (typeof(vforg) == Gen)
    gen(vforg, size)
  else
    vforg
  end
end

# Randomly generate a sign value.
randsign() = randarg(-1, 1)

# Here is an example of how one can generate test data on a given boundary b.
# It always have the values around the boundary in its sequence but can then 
# also "jump" outside of this focused range with a Levy distribution (which has 
# fat tails).
type BoundarySignedGen <: Gen{Signed}
  b::Signed
  d
  subgen
  BoundarySignedGen(b = 0, distr = Levy()) = begin
    sg = SeqGen(b-2, b-1, b, b+1, b+2, 
      () -> b + randsign() * oftype(g.b, floor(rand(g.d))))
    new(b, distr, sg)
  end
end

gen(g) = gen(g.subgen)

type SizedGen{T} <: Gen{Gen{T}}
  size::Integer
  subgen::Gen{T}
end

sized(gen, size = 10) = SizedGen(size, gen)
gen{T}(g::SizedGen{T}, size) = gen(g.subgen, min(size, g.size))

# A data gen just wraps a Julia type into a generator.
#type DataGen{T} < Gen{T}
#  typ::T
#  DataGen(::Type{T}) = new(T)
#end
#gen{T}(dg::DataGen{T}, size = 10) = gen(dg.typ, size)

# A TestGenProcess is the collective generation of a set of values in order to use
# them for testing.
# abstract TestGenProcess

#####################################################################
# (Based on) QuickCheck.jl's generators for the base types
#####################################################################

# Default generators for primitive types
gen{T<:Unsigned}(::Type{T}, size = 10) = convert(T, rand(1:size))
gen{T<:Signed}(::Type{T}, size = 10) = convert(T, rand(-size:size))
gen{T<:FloatingPoint}(::Type{T}, size = 10) = convert(T, (rand()-0.5).*size)
# This won't generate interesting UTF-8, but doing that is a Hard Problem
gen{T<:String}(::Type{T}, size = 10) = convert(T, randstring(size))

# Generator for array's
function gen{T,n}(::Type{Array{T,n}}, size = 10)
  dims = [rand(1:size) for i in 1:n]
  reshape([gen(T, size) for x in 1:prod(dims)], dims...)
end
