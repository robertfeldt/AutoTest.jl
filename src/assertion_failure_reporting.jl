# Given an assertion expression that do not evaluate to true, produce a 
# human readable report describing the failed assertion. 
function assertion_failure_report(expr)
  if typeof(expr) == Expr && expr.head == :comparison
    if expr.args[2] == :(==)
      return join(["Expected ", format(expr.args[1]), " to BE == to ", format(expr.args[3]), ", but it WAS NOT"])
    elseif expr.args[2] == :(!=)
      return join(["Expected ", format(expr.args[1]), " to NOT BE == to ", format(expr.args[3]), ", but it WAS"])
    elseif expr.args[2] == :<
      return join(["Expected ", format(expr.args[1]), " to BE < than ", format(expr.args[3]), ", but it WAS NOT"])
    end
  else
    "<<CANNOT PRINT EXPR>>"
  end
end

function format(d)
  if typeof(d) <: String
    "\"" * string(d) * "\""
  elseif typeof(d) == Expr
    # We strip of the leading and trailing chars marking it's an expression
    string(d)[3:end-1]
  else
    string(d)
  end
end