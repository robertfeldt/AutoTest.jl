using JSON

file_ending(filename) = split(filename, ".")[end]

# Add a json representation of a Julia dict at the end of a json file where we
# assume the last entry in the json in that file is an array of json objects
# so that the last two characters are "]}". We overwrite those two characters
# with the given data object (and then write them there again so that the file
# is a complete json file again).
json_file_insert_in_array_at_end(data, file) = begin
  f = open(file, "a+")

  # position at end-2
  seekend(f)
  skip(f, -2)

  # Now print a comma, then the data and then add the two last chars to make
  # to whole file a valid json again.
  json_raw_print(f, ",")
  JSON.print(f, data)
  json_raw_print(f, "]}")

  close(f)
end

# For printing strings as is rather than with quotes
json_raw_print(stream, string::String) = begin
  jstr = json(string)
  write(stream, jstr[2:end-1])
end

TestExecLogFileName = "test_execution_log.json"
test_execution_log_filename(logDir) = join([logDir, "/", TestExecLogFileName])

# Create the test execution log for the first time.
create_test_execution_log(logDir) = begin
  test_exec_logfile = test_execution_log_filename(logDir)
  f = open(test_exec_logfile, "a+")
  str = json({"test_executions" => [{"st" => strftime("%F %X", time())}]})
  write(f, str)
  close(f)
  test_exec_logfile
end

log_test_execution_stats(testDir, data) = begin
  logdir = join([testDir, "/.autotest"])

  # Create logging dir (and setup files) if not already there...
  if !isdir(logdir)
    mkdir(logdir)
    test_exec_logfile = create_test_execution_log(logdir)
  else
    test_exec_logfile = test_execution_log_filename(logdir)
  end

  # Now append the data
  json_file_insert_in_array_at_end(data, test_exec_logfile)
end

run_all_tests_and_log_stats(testDir, log_test_executions = true;
  changed_file = false,
  regexpThatShouldMatchTestFiles = r"^test.*\.jl$") = begin

  st = time()
  te, stats = run_all_tests_in_dir(testDir, regexpThatShouldMatchTestFiles)

  if log_test_executions
    #println("Logging test exec stats.")

    # We use short keys since we want to keep the size of the json file down
    if changed_file != false
      stats["cf"] = changed_file # Changed file
    end
    stats["st"] = strftime("%F %X", st) # Start time

    # Now log to file.
    log_test_execution_stats(testDir, stats)
  end
end

start_autotesting(srcDir = "src", testDir = "test"; 
  fileendings = ["jl"],
  log_test_executions = true,
  regexpThatShouldMatchTestFiles = r"^test.*\.jl$") = begin

  create_callback(fileChangeDir) = begin
    (filename, events, status) -> begin
      if in(file_ending(filename), fileendings)
        println(join(["=" for i in 1:78]))
        println(strftime("%F %X", time()), ", %File ", filename, " changed. Rerunning tests.")
        run_all_tests_and_log_stats(testDir, log_test_executions; 
          changed_file = join([fileChangeDir, "/", filename]))
      end
    end
  end

  # Run the tests once to ensure the tests have been loaded.
  run_all_tests_and_log_stats(testDir, log_test_executions;
   regexpThatShouldMatchTestFiles = regexpThatShouldMatchTestFiles)

  # Now install the file watchers and sit back and let the autotesting begin... :)
  watch_file(create_callback(srcDir), srcDir)
  watch_file(create_callback(testDir), testDir)
end

