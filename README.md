# HdfsUtils

Ruby gem that provides utilities (ls, find, cat, and others) for
HDFS (Hadoop Distributed File System).

This gem uses the webhdfs interface, which provides fast, compatible,
remote access to files and directories stored in HDFS.

## Environment

The following environment variables may be used to configure the utilities.

<table>
  <tr>
    <th>Variable</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>HDFS_HOST</tt></td>
    <td>The IP hostname of the webhdfs server.</td>
    <td>localhost</td>
  </tr>
  <tr>
    <td><tt>HDFS_PORT</tt></td>
    <td>The IP port number of the webhdfs service.</td>
    <td>50070</td>
  </tr>
  <tr>
    <td><tt>HDFS_USERNAME<tt></td>
    <td>The username used to access HDFS.</td>
    <td>The value of the shell environment USER variable.</td>
  </tr>
  <tr>
    <td><tt>HDFS_URI</tt></td>
    <td>The location of the webhdfs service: <tt>[webhdfs://]hostname[:port]<tt></td>
    <td>webhdfs://localhost:50070</td>
  </tr>
</table>

## Common Options

All of the utilities take the following options, which override the environment variables when specified.

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>--hdfsuri=[webhdfs://]hostname[:port]</tt></td>
    <td>The location of the webhdfs service.</td>
    <td>webhdfs://localhost:50070</td>
  </tr>
  <tr>
    <td><tt>--log-level=[debug|info|warn|error|fatal]</tt></td>
    <td>Logging level.  When <tt>debug</tt> is specified, failures will generate a stack trace.</td>
    <td>fatal</td>
  </tr>
</table>

## Contributing

Altiscale has just started developing hdfsutils.  We're focusing on delivering a specific use case for one of our customers, but intend to build a much more complete set of utilities.  Contributions are welcome.

To add new functionality to an existing utility, you'll probably want to edit the utility's options.rb file and the utility implementation.

To develop a completely new utility: find, copy, and modify the template code.  Here's the current list of template code files at the time that this documentation was written:
```
$ find . -path '*template*'
./bin/htemplate
./lib/hdfsutils/utils/htemplate
./lib/hdfsutils/utils/htemplate/implementation.rb
./lib/hdfsutils/utils/htemplate/options.rb
./lib/hdfsutils/utils/htemplate/template.rb
./spec/utils/htemplate_spec.rb
```

The code in all pull requests must pass the rubocop and rspec tests.  New functionality should be submitted with corresponding rspec unit tests.  The best way to run rubocop and rspec is to use rvm, bundler, and rake.  Assuming that rvm is already installed with bundler in the default gemset, run rake as follows:
```
$ rvm use @hdfsutils-devel --create
ruby-2.0.0-p353 - #gemset created /Users/chaiken/.rvm/gems/ruby-2.0.0-p353@hdfsutils-devel
ruby-2.0.0-p353 - #generating hdfsutils-devel wrappers..........
Using /Users/chaiken/.rvm/gems/ruby-2.0.0-p353 with gemset hdfsutils-devel
```
bash-3.2$ bundle install
Fetching gem metadata from https://rubygems.org/............
Fetching version metadata from https://rubygems.org/..
Resolving dependencies...
<installs the development dependencies in hdfsutils.gemspec>
Bundle complete! <D> Gemfile dependencies, <G> gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
bash-3.2$ rake
Running RuboCop...
Inspecting <F> files
..............................

<F> files inspected, no offenses detected
<path>/ruby <path>/rspec --pattern spec/\*\*\{,/\*/\*\*\}/\*_spec.rb

HdfsUtils::Ls
<ls utility tests>

HdfsUtils::Template
<template utility tests>

Finished in <N> seconds (files took <M> seconds to load)
<X> examples, <F> failures
```
