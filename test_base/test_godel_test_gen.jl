facts("GodelTest generators") do

  g = @generator "SeqOfExprGen" begin
  end

  @fact g.desc => "SeqOfExprGen"

end