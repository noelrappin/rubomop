# Rubomop

Rubomop cleans up after your Rubocop.

It allows you to randomly delete items from your `rubocop_todo.yml` file and
then rerun Rubocop.

Options include

* The number of items to delete (default: 10)
* Whether to limit to autocorrectable cops (default: true)
* Whether to automatically run `rubocop -a` after deletion

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rubomop"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubomop

## Usage

```
$ rubomop --help 
Usage: rubomop [options]
    -n, --number NUMBER              Number of cleanups to perform (default: 10)
    -a, --autocorrect_only           Only clean autocorrectable cops (default)
        --no_autocorrect_only        Clean all cops (not default)
    -r, --run_rubocop                Run rubocop -aD after (default)
    -f, --filename FILENAME          Name of todo file (default: ./.rubocop_todo.yml)
        --no_run_rubocop             Don't run rubocop -aD after (not default)
    -h, --help                       Prints this help
```

## Development


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubomop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rubomop/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubomop project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubomop/blob/main/CODE_OF_CONDUCT.md).
