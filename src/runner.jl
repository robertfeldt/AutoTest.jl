module AutoTest

export spec

type Spec
  level::Int64
  description::ASCIIString
  parent::Union(Nothing, Spec)
  children
  num_pass::Int64
  num_fail::Int64
  next_column::Int64 # Next column to print progress in

  Spec(desc, level = 0, parent = nothing) = new(level, desc, parent, Any[], 0, 0, level)
end

CurrentSpec = TopSpec = Spec("<top>")

num_pass(x) = 0
num_fail(x) = 0
num_pass(s::Spec) = s.num_pass + sum([num_pass(c) for c in s.children])
num_fail(s::Spec) = s.num_fail + sum([num_fail(c) for c in s.children])

function spec(body, description = "")
  global CurrentSpec
  global TopSpec
  new_spec = Spec(description, CurrentSpec.level+1, CurrentSpec)  
  push!(CurrentSpec.children, new_spec)
  old_spec = CurrentSpec
  CurrentSpec = new_spec
  leading = reps("-", old_spec.level)
  print("\n", leading, description, ":\n", reps(" ", old_spec.level))
  body()
  CurrentSpec = old_spec
end

function report_assertions()
  if CurrentSpec == TopSpec
    # Back at the top-level so print info about the number of pass and fail
    np = num_pass(CurrentSpec)
    nf = num_fail(CurrentSpec)
    println("\n\n", np+nf, " asserts, ", np, " passed, ", nf, " failed\n")
  end
end

function reps(str, len)
  join([str for i in 1:len], "")
end

function mark_progress(char)
  if CurrentSpec.next_column == 78
    CurrentSpec.next_column = 0
    print(reps(" ", CurrentSpec.level))
  end
  print(char)
  CurrentSpec.next_column += 1
end

function log_outcome(outcome)
  global CurrentSpec
  if outcome == true
    CurrentSpec.num_pass += 1
    mark_progress(".")
  else
    CurrentSpec.num_fail += 1
    mark_progress("F")
  end
end

macro pp(ex)
  quote
    print($(string(ex)), " = ")
    show($(ex))
    println("")
  end
end

macro assert(ex)
  quote
    global CurrentSpec
    if $ex
      log_outcome(true)
      nothing
    else
      log_outcome(false)
      print("\n", reps(" ", CurrentSpec.level-1), "Assertion failed: ", $(string(ex)), "\n", reps(" ", CurrentSpec.level-1))
    end
  end
end

# A DataGenMapper maps regexp's to generator calls. All the regexp's that match
# a data gen spec are valid for it. One of them is randomly selected and the
# func it maps to is called to generate a data which is fed to the variable
# name given in the data gen spec.
type GenFromStringSpec
  map
  GenFromStringSpec() = new({})
end

StringSpecGen = GenFromStringSpec()

function reg(regexp, genfunc)
  global StringSpecGen
  StringSpecGen.map[regexp] = genfunc
end

function lookup(dataspec)
  global StringSpecGen
  res = Any[]
  for(regexp in keys(StringSpecGen))
    var = match(regexp, dataspec)
    if (var)
      push!(res, (var, StringSpecGen[regexp]))
    end
  end
  if (length(res) > 0)
    return res[rand(1:length(res))]
  else
    return false, (size) -> nothing
  end
end

#macro given(body, dataspecs)
#  quote
#    for(dspec in ($dataspecs))
#    end
#  end
#end

end

using AutoTest

# Now lets test it:
spec("A") do
  @assert true
  spec("B") do
    @assert true
    @assert true
    a = 1
    @assert a == 2
    @assert true
    @assert true
    spec("C") do
      @assert true
      k = false
      @assert k != false
    end
  end
end

spec("A2") do
  @assert true
end

report_assertions()