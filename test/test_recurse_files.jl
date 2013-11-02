facts("recurse_and_find_all_files_matching") do
  files = Any[]
  cb(filepath) = push!(files, filepath)
  AutoTest.Utils.recurse_and_find_all_files_matching(cb, "test")

  @fact in("test/test_recurse_files.jl", files) => true
  @fact length(files) > 1 => true
end