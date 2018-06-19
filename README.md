# Pltt - pludoni Time Tracker Gitlab CLI interface

[![Gem Version](https://badge.fury.io/rb/pltt.svg)](https://badge.fury.io/rb/pltt)

Pltt is a Gitlab Time Tracker client for the command line. It mimics the interface of [kriskbx/gitlab-time-tracker]( https://github.com/kriskbx/gitlab-time-tracker ) and is compatible to the config and frame database. Thus, it works as a drop-in-replacement.

Goals/differences to gtt:

* More helpful actions:
  * ``pltt start`` - can be called without issue id and displays a CLI select to choose the issue to book on
  * ``gtt stop`` - possible to fix issue start time / duration there
  * ``gtt create`` - creates issue on Gitlab immediately, can input title, select labels, enter description and also optionally create a branch/MR (like the button in Gitlab Web) and immediately switch to that
* More robust interface with Gitlab:
  * Not possible to book on non-existing or closed issues
  * Time Entries are booked on stop by default, so no date shifting for forgotten frames
  * pltt status shows issue body, milestone etc. too
* Fast interface, even though it's ruby, the boot time is comparable or faster than the Nodejs version
  * ``gtt status  0,87s user 0,10s system 110% cpu 0,883 total``
	* ``pltt status  0,49s user 0,04s system 71% cpu 0,741 total``
	* -> even though pltt status does more (fetches whole issue title, description etc from Gitlab), it is faster
  * ``gtt start 79  0,87s user 0,10s system 111% cpu 0,867 total``
	* ``pltt start 79  0,47s user 0,06s system 70% cpu 0,758 total``
	* -> again, pltt does more - it makes an API request to gitlab to validate that issue exists and is not closed.
  * optimizations:
    * Dependency minimizations - only necessary deps (gitlab api, tty, thor, oj, hashids)
    * most actions, like status etc only looks for the most recent frames in the framedir before parsing the JSON, so a larger framedir has a smaller effect on performance
    * smaller code size, e.g. currently ~500 LOCs Ruby vs. >3000 LOCs JS


## Notable limitations of Gitlab's API and thus also for this Gem

* Gitlab's Time Tracking database is more or less append-only. So, once synced entries are undeletable by this client. If you need to fix some time tracking entry, you need to manually subtract that in the Issue, like "-3h"
* Gitlab's Time Tracking API (and web client too) has no means of specifying the date/time of the spend entry. This is why, the entry is always posted as "right now". There is an [Issue](https://gitlab.com/gitlab-org/gitlab-ce/issues/47324) about that. One of the motivations of this client was, that after stopping entries, they are synced immediately

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

### Stopping, Syncing and Maintenance

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
* [ ] No delete implemented, as cancel is enough. Deleting frames is also not very useful, when they are already synced to Gitlab

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pludoni/pltt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
