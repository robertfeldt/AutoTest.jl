MainFile = "src/AutoTest.jl"

def runtestfile(filename)
  if File.exist?(filename)
    sh "julia -L #{MainFile} #{filename}"
  else
    # puts "No test file named #{filename} found."
  end
end

task :runbasetest do
  runtestfile "test_base/runtests.jl"
end

task :runtest do
  runtestfile "test/runtests.jl"
end

task :runselftest do
  sh "julia -L #{MainFile} -L test/helper.jl -e 'AutoTest.run_all_tests_in_dir(\"test\"; verbosity = 2)'"
end

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

desc "Run only the latest changed test file"
task :t do
  latest_changed_test_file = filter_latest_changed_files Dir["test/**/test*.jl"]
  sh "julia -L #{MainFile} -L test/helper.jl -e 'AutoTest.run_tests_in_file(\"#{latest_changed_test_file.first}\"; verbosity = 2)'"
end

task :at => :runtest
task :bt => :runbasetest
task :default => :runtest