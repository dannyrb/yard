# YARD: Yay! A Ruby Documentation Tool

This is a simple console app used to demonstrate the benefits of YARD.

## Usage

```bash
# No Arguments, prints a "help" message
ruby RailsCLI.rb

# Call a specific task w/ arguments
# ex: ruby RailsCLI.rb <task> [arg1 arg2]
ruby RailsCLI.rb new verbose
```

### Generate API Docs

Required `gem install yard`

```bash
#
yard server --reload **/*.rb

# https://msp-greg.github.io/yard/YARD/CLI/Yardoc.html
yardoc [options] [source_files [- extra_files]]

```

## On Ruby CLIs

- [ARGV array](https://www.rubyguides.com/2018/12/ruby-argv/) (how to access CLI options)
- [OptParse Library](https://rubyreferences.github.io/rubyref/stdlib/cli/optparse.html) (Built into Ruby)
- [Thor gem](http://whatisthor.com/) (What Ruby's CLI uses)
