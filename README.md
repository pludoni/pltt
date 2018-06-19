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

### Starting Time Tracking

```bash
# start without issue id -> shows a selection menu of 30 most recent issues in project
pltt start

# start with issue id -> validates issue exists and is not closed
pltt start 123

# create new issue with interactive question for issue creation
# issue will be created instantly, not on sync
# You can enter issue title, select labels, and description
pltt create

# Starts time tracking with
pltt resume
```

### Stopping, Synching and Maintenance

```bash
# stops time tracking & syncs to gitlab
# 2 interactive questions can easly fix missing started entries
# can adjust start time and duration (minutes)
pltt stop

# Edit current entry in EDITOR
pltt edit
pltt edit 19ad20

# Cancel = delete current running entry
pltt cancel

# normally not needed, as sync is made after stop, only in case of error
pltt sync
```

### Reporting / General

```bash
# show all issues in project as table
pltt list
pltt list --my
pltt list --label Bug
```

## Development

Missing before release:

* [x] gtt start with no arguments shows the list of open issues to select one from
* [x] gtt create can optionally create a MR + branch
* [x] gtt stop / sync note creation
* [ ] First-Start Guide, Generator which creates .gtt.yml in a project, gets the project url from .git/config
* [ ] Timezone
* [ ] Frame Cleanup, everything older than X month can delete

Missing, but not planned soon, as not needed by us:

* [ ] Logging/reporting of all bookings
* [ ] No Booking on Merge requests implemented
* [ ] No delete implemented, as cancel is enough. deleting frames is also not very useful, when they are already synced to Gitlab

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pludoni/pltt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
