# lmcadm

The lmcadm command line utility strives to provide an admin and script friendly interface to select LMC functionality.

## Installation

Install via rubygems:

    $ gem install lmcadm

### Requirements
Building native extensions for certain dependencies require ruby headers or source code to be present.
These can usually be installed the same way ruby was installed.

On Ubuntu for example, installing the `ruby-dev` via the package manager is sufficient.

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lmcadm.
The sentence above is patently wrong currently.

## License

The gem is available as open source under the terms of the BSD 3-Clause License.
