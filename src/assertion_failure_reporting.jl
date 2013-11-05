function show_if_differ(f1, f2, inbetween = " was ")
  (f1 == f2) ? "" : join([f1, inbetween, f2])
end

function report_failed_comparison(comparisonstr, showlhs, showrhs)
  if length(showlhs) > 0 && length(showrhs) > 0
    spec = join(["\n but ", showlhs, ", and\n     ", showrhs])
  elseif length(showlhs) > 0 || length(showrhs) > 0
    spec = join(["\n but ", showlhs, showrhs])
  else
    spec = " to be true (which it is NOT!!)"
  end

  join(["Expected ", comparisonstr, spec])
end

# Safe evaluation of an expression in the calling context. Catches any
# exceptions and returns them. If no exception then returns the results
# of the evaluation, otherwise return the exception.
# expression
macro safeesceval(ex)
  quote
    local exception
    try
      $(esc(ex))
    catch exception
      exception
    end
  end
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

macro asrt(ex)
  local extype, lhs, rhs, comparator, assertion_str, flhs, frhs, showlhs, showrhs, exception

  if typeof(ex) == Expr && ex.head == :comparison
    extype = :comparison
    lhs = ex.args[1]
    comparator = ex.args[2]
    rhs = ex.args[3]
    flhs = format(lhs)
    frhs = format(rhs)
    assertion_str = join([flhs, " ", format(comparator), " ", frhs])
  else
    extype = :unknown
    # All variables need to be have values for the quoted expression below
    # to compile! We set a dummy value.
    frhs = flhs = rhs = lhs = nothing
    assertion_str = join(["Expected ", format(ex), " to be true (which it is NOT!!)"])
  end

  quote
    local res = nothing
    try
      res = $(esc(ex)) # $(@safeesceval(ex))
    catch exception
      res = :error
      return (:error, exception)
    end
    if res == true
      (:pass, nothing)
    elseif res == false
      if $(extype == :comparison)
        # We do NOT need to safeeval since these parts of the expr above
        # has already been evaluated and we would not come here if they raised
        # an exception.
        local vlhs = $(esc(lhs))
        local vrhs = $(esc(rhs))
        showlhs = show_if_differ($flhs, format(vlhs))
        showrhs = show_if_differ($frhs, format(vrhs))
        (:fail, report_failed_comparison($assertion_str, showlhs, showrhs))
      else
        (:fail, $assertion_str)
      end
    else
      (:error, res)
    end
  end
end
