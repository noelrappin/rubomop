# Rubomop

Rubomop cleans up after your Rubocop.

It allows you to randomly delete items from your `rubocop_todo.yml` file and
then rerun Rubocop.

Please note -- this is probably something you should do with caution, if you
run this, make sure you inspect the changes before you acutally commit them
back to your repo. Run your tests. 

This could definitely mess things up if the Rubocop autocorrects change the
meaning of your code

Use at your own risk

Options include

* The number of items to delete (default: 10)
* Whether to limit to autocorrectable cops (default: true)
* Whether to automatically run `rubocop -a` after deletion
* A configuration file at `.rubomop.yml`
* A list of cops to only include for deletion
* A list of cops to exempt from deletion
* A list of files to exempt from change

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
    -a, --autocorrect-only           Only clean autocorrectable cops (default)
        --no_autocorrect-only        Clean all cops (not default)
    -r, --run-rubocop                Run rubocop -aD after (default)
    -f, --filename=FILENAME          Name of todo file (default: ./.rubocop_todo.yml)
        --no-run-rubocop             Don't run rubocop -aD after (not default)
    -c, --config=CONFIG_FILE         Name of optional config file (default: .rubomop.yml)
        --only=ONLY                  String or regex of cops to limit removal do, can have multiple
        --except=EXCEPT              String or regex of cops to limit removal do, can have multiple
        --block=BLOCK                String or regex of files to not touch, can have multiple
    -h, --help                       Prints this help

```

The `--only` option allows you to limit cops to be selected from to only 
those listed, the option can be a string or regular expression, and you can 
have more than one. 

The `--except` option allows you to specify a cop that should not be 
selected, again, the option can be a string or a regular expression, and you 
can have more than one. If a cop is in both the `--except` and `--include` 
lists for some reasone, the except list wins and it's excluded.

The `--block` option allows you to specify files that should not be selected 
for any cops. The option can be a string or a regular expression and you can 
have more than one. If a cop/file combination is in both the `--include` 
cops list and the file `--block` list, the block wins and the file is not 
included. 

You can also put options in a `rubomop.yml` file, or you can put it in a 
different location with the `-c` option from the command line.

```yaml
number: 10
autocorrect-only: true
only:
  - Lint*
block: 
  - oops*
```

If an option is set via the config file and the command line, the command 
line option wins. This is true even for the list options where you can have 
more than one, the command line completly blocks the config file from being 
used.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubomop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rubomop/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubomop project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubomop/blob/main/CODE_OF_CONDUCT.md).
