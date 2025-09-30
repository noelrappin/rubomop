## [1.0.1] - 9/30/2025
- remove awesome_print from runtime dependency

## [1.0.0] - 7/31/2025

- Allow for a second run type that removes a specific cop from the todo
- Allow for running the cleanup on a different directory
- Allow for the difference between safe and unsafe autocorrect
- Drop support for Ruby 3.1 and lower
- Handles the case where Rubocop puts criteria and not exclusions in the to-do

## [0.3.0] - 2022-08-12

- More accurately update offense count in todo file after running rubocop

## [0.2.0] - 2022-07-22

- Adds for a .rubomop.yml file with configuration options
- Command line switch to override config file name
- Allows for only/except for specific cops by name or pattern 
- Allows for excluding specific file patterns from being changed
- Only runs rubocop on selected files, not on the whole repo

## [0.1.0] - 2022-07-20

- Initial release
