recurse_and_find_all_files_matching(callback, dir, regexp = r".*") = begin
  for(file in readdir(dir))
    println(file)
    filepath = join([dir, "/", file])
    println(filepath)
    if isdir(filepath)
      recurse_and_find_all_files_matching(callback, filepath, regexp)
    elseif match(regexp, filepath) != nothing
      callback(filepath)
    end
  end
end
