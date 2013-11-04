# Coloring is based on FactCheck
const RED     = "\x1b[31m"
const GREEN   = "\x1b[32m"
const BLUE    = "\x1b[34m"
const BOLD    = "\x1b[1m"
const DEFAULT = "\x1b[0m"
const REDBOLD = "\x1b[31;1m"
const GREENBOLD = "\x1b[32;1m"
const BLUEBOLD = "\x1b[34;1m"

colored(s, color) = string(color, string(s), DEFAULT)
red(s)            = colored(string(s), RED)
green(s)          = colored(string(s), GREEN)
blue(s)           = colored(string(s), BLUE)
bold(s)           = colored(string(s), BOLD)
redb(s)           = colored(string(s), REDBOLD)
greenb(s)         = colored(string(s), GREENBOLD)
blueb(s)          = colored(string(s), BLUEBOLD)

colorif(value, color, s, v = 0) = begin
  (value > v) ? colored(s, color) : string(s)
end

colorif(value, color, a::Array{Any,1}, v = 0) = begin
  colorif(value, color, join([string(e) for e in a], ""), v)
end
