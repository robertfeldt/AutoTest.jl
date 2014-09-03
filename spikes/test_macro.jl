# Find variable references in Expr's.
function findvars(expr)
  if typeof(expr) <: Symbol
    return Symbol[expr] # a symbol refers to a variable
  elseif typeof(expr) <: Expr
    if expr.head == :comparison
      return vcat(findvars(expr.args[1]), findvars(expr.args[3]))
    elseif expr.head == :call
      # Look for vars in args from 2 and on since arg 1 is the function name
      return vcat(map(findvars, expr.args[2:end])...)
    end
  end
  return Symbol[] # No vars found
end

type AssertionFailure <: Exception
  condition
  varvaluemap
end

import Base.string
function string(af::AssertionFailure)
  "expected $(af.condition) to be true but it is not, since\n" * join(["$k is $v" for (k,v) in af.varvaluemap], ",\n")
end

macro test(e)
  vars = findvars(e)
  varvaluesexpr = Expr(:vcat, vars...)
  quote
    local got = $(esc(e))
    # local passed = $(esc(e)) == true
    if got != true
      af = AssertionFailure($(string(e)), Dict($(vars), $(esc(varvaluesexpr))))
      println(string(af))
      throw(af)
    end
  end
end

macro t(e)
  :(@test($(e)))
end

af = AssertionFailure("a < 1", Dict([:a], [2]))
string(af)

a = 1
@t a < 2
a = 10
@t a < 1
@t a > 0
a = 1
b = 0
@t a < b
@t a >= 2

type D
  i
  j
end

d = D(1,2)
@t d.i > d.j