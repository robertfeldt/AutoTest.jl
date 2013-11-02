MainFile = "src/AutoTest.jl"

def runtestfile(filename)
  if File.exist?(filename)
    sh "julia -L #{MainFile} #{filename}"
  else
    # puts "No test file named #{filename} found."
  end
end

task :runbasetest do
  runtestfile "test/runbasetests.jl"
end

task :runtest do
  runtestfile "test/runtests.jl"
end

task :runslowtest do
  runtestfile "test/runslowtests.jl"
end

task :runselftest do
  runtestfile "test/selftest/runtests.jl"
end

task :runalltest => [:runbasetest, :runtest, :runslowtest, :runselftest]

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

desc "Run only the latest changed test file"
task :t do
  latest_changed_test_file = filter_latest_changed_files Dir["test/test*.jl"]
  sh "julia -L #{MainFile} -L test/helper.jl #{latest_changed_test_file.first}"
end

task :at => :runalltest
task :st => :runslowtest

task :default => :runalltest