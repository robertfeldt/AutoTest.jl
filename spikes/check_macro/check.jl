include("varvaluesmap.jl")

spaces(n) = join([" " for i in 1:n])

function format_varvalues(dict)
  if length(dict) == 0
    return ""
  end
  maxlenvarname = maximum(map((k) -> length(string(k)), keys(dict)))
  join(map(sort(collect(keys(dict)))) do key
    sp = spaces(maxlenvarname - length(string(key)))
    "$(string(key))$sp was $(dict[key])"
  end, "\n   ")
end

abstract Result
immutable Success <: Result
  expr
end
immutable Failure <: Result
  expr
  resolvedexpr
  varvalues
  Failure(expr, rexpr = nothing, vv = {}) = new(expr, rexpr, vv)
end
immutable Error <: Result
  expr
  err
  backtrace
  varvalues
  Error(expr, err, vv = {}) = new(expr, err, catch_backtrace(), vv)
end

report_check(s::Success) = println("success!")
report_check(f::Failure) = begin
  vvmapstr = format_varvalues(f.varvalues)
  if length(vvmapstr) > 0
    println("check failed: $(string(f.resolvedexpr))\n in expression $(f.expr)\n  since\n   $vvmapstr")
  else
    println("check failed: $(string(f.resolvedexpr))\n in expression $(f.expr)")
  end
end
report_check(e::Error) = begin
  println("error thrown in check: $(e.expr)\n $(e.err)")
  println(e.backtrace)
end

macro check(origexpr)
  vvmap = varvaluesmap(findvars(origexpr))
  quote
    local vvm = $vvmap
    local origexprstr = $(string(origexpr))
    try
      if ($origexpr)
        report_check(Success(origexprstr))
      else
        local rexpr = resolveexpr($(Expr(:quote,origexpr)), vvm)
        report_check(Failure(origexprstr, string(rexpr), vvm))
      end
    catch err
      report_check(Error(origexprstr, err, vvm))
    end
  end
end

function resolveexpr(expr, varvaluemap)
  if typeof(expr) <: Symbol
    ex = haskey(varvaluemap, expr) ? varvaluemap[expr] : expr
    return ex
  elseif typeof(expr) <: Expr
    if expr.head == :comparison
      # Eval sides before returning?? And update varvaluemap with sides?
      return Expr(expr.head, map((e) -> resolveexpr(e, varvaluemap), expr.args)...)
    else
      return Expr(expr.head, map((e) -> resolveexpr(e, varvaluemap), expr.args)...)
    end
  else
    return expr
  end
end

a = 1
b = 2
@check a == b
@check a < b
@check a+1 < b
@check 2*(a+1) < 1.5*b
f(x) = 2*x
@check f(1) > 3