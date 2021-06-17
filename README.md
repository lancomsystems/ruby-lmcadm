# lmcadm

The lmcadm command line utility strives to provide an admin and script friendly interface to select LMC functionality.

## Installation

Install via rubygems:

    $ gem install lmcadm

### Requirements
Building native extensions for certain dependencies require ruby headers or source code to be present.
These can usually be installed the same way ruby was installed.

On Ubuntu for example, installing the `ruby-dev` via the package manager is sufficient.

### Windows

Lmcadm works with https://rubyinstaller.org/downloads/, use the recommended version with Devkit and choose the default options during install.
Installation can continue with rubygems.

#### Known issues
*Installing lmcadm fails with `ERROR: Failed to build gem native extension.`*

Ruby headers and some tools to build software (C compiler, make) are needed.
On Ubuntu for example, the packages `ruby-dev` and `build-essential` should be enough.
    apt install ruby-dev build-essential

*Unable to load the EventMachine C extension ; To use the pure-ruby reactor, require 'em/pure_ruby'*

Workaround: Reinstall eventmachine with --platform ruby.

    gem uninstall eventmachine  (select all versions if prompted)
    gem install eventmachine --platform ruby

## Usage

The primary usage documentation is in the help output of lmcadm:

    $ lmcadm help

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Using a local version of the lmc gem

Set the environment variable LMCADM\_PATH\_DEP to 1 to use the _lmc_ gem from ../ruby-lmc.
Example:
    $ LMCADM_PATH_DEP=1 bundle exec lmcadm --version

### Building an exe for windows using ocra

* Apply workaround reinstalling eventmachine (see above)
* run ocra.sh

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lmcadm.
The sentence above is patently wrong currently.

## License

The gem is available as open source under the terms of the BSD 3-Clause License.

# Advanced usage or experimental features

## Using lmcadm to query monitoring data

Example use:

    lmcadm monitor -A "ExampleProject" raw device_info cloud_rtt 42adf60b-0fe7-4187-af4f-9ee97669bfb0

### --type scalar (default)

When specifying a period longer than MINUTE1, the name must be suffixed with a dot, followed by an aggregation type.
Available types are
* .min
* .max
* .avg

Example use:

    lmcadm monitor -A "ExampleProject" raw --type scalar --period MINUTE10 \
        device_info cloud_rtt.max 3e19ada7-86fa-4809-a14e-7174b018603d


### --type json

This dumps the raw values response as json.
To further extract data, use something that can parse json, like `jq`[1].

Example use:

    lmcadm monitor -A "SDN-DEMO (LANCOM Visitor)" raw --type json --period MINUTE1 \
      wan_info_json interfaces a6871a81-84f3-4c57-a20e-c3410b47e895  | jq ' .[]["DSL-CH-1"].rxRate'

# Footnotes
[1] https://stedolan.github.io/jq/manual/