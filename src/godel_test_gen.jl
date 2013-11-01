macro pp(e)
  :(println($(string(e)), " = ", $e))
end

# Extract assignment rules in the body of a generator macro. Assignment rules
# are the methods of a generator.
function extract_rules(elements)
  rules = Any[]
  for(i in 1:length(elements))
    if elements[i].head == symbol("=")
      push!(rules, (elements[i].args[1], elements[i].args[2]))
    end
  end
  rules
end

function extract_function_name(assignmentLhs)
  rm = match(r"^([a-z][a-zA-Z_0-9]*)\(\)", string(assignmentLhs))
  if rm
    rm[1]
  else
    nothing
  end
end

macro g(desc, body)
  @pp desc
  @pp body.head
  rules = extract_rules(body.args)
  @pp rules
end

@g "SeqOfExprGen" begin
  start() = join(plus(expression()))
  expression() = "1"
end

# This is the example from our ISSRE paper:
#
#@generator(SeqOfExprGen, large_left = 3) begin
#  start(g) = plus(expression(g))
#  expression(g) = begin
#    if g.large_left < 1
#      return number()
#    end
#    g.large.left -= 1
#    "(" * expression(g) * operation() * expression(g) * ")"
#  end
#  expression(g) = number()
#  operation() = "+"
#  operation() = "-"
#  number() = "$(rand(1:10))"
#end