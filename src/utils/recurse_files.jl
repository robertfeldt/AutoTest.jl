recurse_and_find_all_files_matching(callback, dir, regexp = r".*") = begin
  for(file in readdir(dir))
    filepath = join([dir, "/", file])
    if isdir(filepath)
      recurse_and_find_all_files_matching(callback, filepath, regexp)
    elseif match(regexp, filepath) != nothing
      callback(filepath)
    end
  end
end
