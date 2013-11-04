# Given a comparison expression that do not evaluate to true, produce a 
# human readable report describing it.
function report_failed_comparison(e, lhs, rhs)
  showlhs = show_value_if_differ(e.args[1], lhs)
  showrhs = show_value_if_differ(e.args[3], rhs)

  if length(showlhs) > 0 && length(showrhs) > 0
    spec = join(["\n     but ", showlhs, "\n", "      and ", showrhs, "\n"])
  elseif length(showlhs) > 0 || length(showrhs) > 0
    spec = join(["\n     but ", showlhs, showrhs, "\n"])
  else
    spec = "!!!\n"
  end

  join(["Expected ", 
    format(e.args[1]), " ", format(e.args[2]), " ", format(e.args[3]), 
    spec])
end

function show_value_if_differ(v1, v2, inbetween = " was ")
  f1, f2 = format(v1), format(v2)
  (f1 == f2) ? "" : join([f1, inbetween, f2])
end

isexpr(d) = typeof(d) == Expr

function format(d)
  if typeof(d) <: String
    "\"" * string(d) * "\""
  elseif isexpr(d) && length(string(d)) > 3
      # We strip of the leading and trailing chars marking it's an expression
      string(d)[3:end-1]
  else
    string(d)
  end
end