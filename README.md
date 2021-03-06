# CKick [![Build Status](https://travis-ci.org/jonathangingras/ckick.svg?branch=master)](https://travis-ci.org/jonathangingras/ckick) [![Code Climate](https://codeclimate.com/github/jonathangingras/ckick/badges/gpa.svg)](https://codeclimate.com/github/jonathangingras/ckick)

CKick is a simple gem that helps to kick start a C/C++ project using CMake with an arbitrary structure.
Using a `CKickfile`, ckick is able to generate an whole project structure without having to write any `CMakeLists.txt` by your own.

## Usage

    $ cd your/c_cxx/project/path
    # edit CKickfile
    $ ckick

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonathangingras/ckick.
