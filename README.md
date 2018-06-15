# Pltt

Pltt is a Gitlab Time Tracker for the command line. It mimicks the interface of [kriskbx/gitlab-time-tracker]( https://github.com/kriskbx/gitlab-time-tracker ) and is compatible to the config and frame database. Thus, it works as a drop-in-replacement.

Goals/Pros:

* Fast interface, even though it's ruby, the boot time is faster right now
* More friendly interface, error persistent, e.g. forgotten stoppings, issue creation with question-response cycles
* More robust interface with Gitlab:
  * Not possible to book on non-existend or closed issues
  * Time Entries are booked on stop by default, so no time shifting
  * pltt status shows issue body, milestone etc. too

## Installation

Install it yourself as:

    $ gem install pltt

## Usage

```
pltt
```

## Development

Missing before release:

* [ ] gtt start with no arguments shows the list of open issues to select one from
* [ ] First-Start Guide, Generator which creates .gtt.yml in a project, gets the project url from .git/config
* [ ] gtt stop / sync note creation
* [ ] Timezone

Missing, but not planned soon, as not needed by us:

* [ ] Logging/reporting of all bookings

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pludoni/pltt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
