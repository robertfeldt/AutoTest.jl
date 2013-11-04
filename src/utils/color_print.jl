# Printing in nice colors to the terminal.
# Copyright (c) Robert Feldt 2013 (robert.feldt@gmail.com)
# 
# For license details see the LICENSE.md file in the top dir of the repository
# where you found this file.
#

# Find more details on color printing to terminal here:
#  http://en.wikipedia.org/wiki/ANSI_escape_code
const RED       = "\x1b[31m"
const GREEN     = "\x1b[32m"
const BLUE      = "\x1b[34m"
const BOLD      = "\x1b[1m"
const RESET     = "\x1b[0m"
const REDBOLD   = "\x1b[31;1m"
const GREENBOLD = "\x1b[32;1m"
const BLUEBOLD  = "\x1b[34;1m"

annotate(s, color) = string(color, string(s), RESET)
red(s)             = annotate(string(s), RED)
green(s)           = annotate(string(s), GREEN)
blue(s)            = annotate(string(s), BLUE)
bold(s)            = annotate(string(s), BOLD)
redb(s)            = annotate(string(s), REDBOLD)
greenb(s)          = annotate(string(s), GREENBOLD)
blueb(s)           = annotate(string(s), BLUEBOLD)

annotateif(cond, color, s) = cond ? annotate(s, color) : string(s)

annotateif(cond, color, a::Array{Any,1}) = begin
  joinedstr = join([string(e) for e in a])
  annotateif(cond, color, joinedstr)
end
