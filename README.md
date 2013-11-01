AutoTest.jl
===========

AutoTest is a testing framework for Julia (julialang.org). It aims to be small and simple while still supporting advanced functionality such as test data generation and automated test execution and reporting.

# Installation

Just install from the github by calling:

    Pkg.clone("https://github.com/robertfeldt/AutoTest.jl")

from a Julia repl.

# Usage

TBD

# State of the Library

* Test data generation
 - Generators for sequences of values, functions generating values and (sub-)generators

## Planned features

* Nice reporting of tests that passed and failed.
* GodelTest generators
* given / then way of specifying general problem classes in plain text