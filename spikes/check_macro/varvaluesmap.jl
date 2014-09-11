# Find variable references in an expression.
function findvars(expr)
  if typeof(expr) <: Symbol
    return Symbol[expr] # a symbol refers to a variable so we need to save its value for error reporting
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

gensyms(n) = [gensym() for i in 1:n]

# Create an expression that creates and returns a Dict mapping the varnames
# to their values in the context where the expr is evalued.
function varvaluesmap(varnames)
  n = length(varnames)
  syms = gensyms(n)
  assignments = map(1:n) do vi
    :($(syms[vi]) = $(esc(varnames[vi])))
  end
  blstmt = Expr(:block, assignments...)
  push!(blstmt.args, :(Dict($varnames, [$(syms...)])))
  blstmt
end

macro t(expr)
  varvaluesmap(findvars(expr))
end

a = 1
b = 2
@t a + b
a = 3
@t (2*a + b / a)
