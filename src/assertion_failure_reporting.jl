# Given an assertion expression that do not evaluate to true, produce a 
# human readable report describing the failed assertion. 
function assertion_failure_report(expr)
  if expr.head == :comparison
    if expr.args[2] == :(==)
      return join(["Expected ", string(expr.args[1]), " to BE == to ", string(expr.args[3]), ", but it WAS NOT"])
    elseif expr.args[2] == :(!=)
      return join(["Expected ", string(expr.args[1]), " to NOT BE == to ", string(expr.args[3]), ", but it WAS"])
    end
  else
    string(expr)
  end
end