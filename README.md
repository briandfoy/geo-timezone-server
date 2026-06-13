## geo-timezine server

I had a local time and geocoordinates, but I needed the timezone, so here you go.

I barely did anything. All the hard work was already done by the [Geo::Location::TimeZoneFinder](https://metacpan.org/pod/Geo::Location::TimeZoneFinder) Perl module and the [evansiroky/timezone-boundary-builder)](https://github.com/evansiroky/timezone-boundary-builder) project. I just wrapped a Mojolicious Lite app around it so my other tasks can query it.

This is all under the Artistic License 2.0. Basically do whatever you like with it. If you want to support it, see about supporting the Perl module or the GitHub project.

## Set up

This needs Perl v5.42, Mojolicious 9, and Time::Str:

	% cpan Mojolicious Time::Str

Or use the *cpanfile*:

	% cpanfile --installdeps .

You need the timezone shape files from [evansiroky/timezone-boundary-builder)](https://github.com/evansiroky/timezone-boundary-builder).

Download the latest [timezones-1970.shapefile.zip](https://github.com/evansiroky/timezone-boundary-builder/releases/). There are two ways that you can position this directory:

* Unzip the release in the same directory as *geo-timezone*
* Put it somewhere else and set the `TIMEZONES_1970` environment variable

There's a trick, though. The path to the file has to be the directory and the file basename without the file extension, such as *timezones-1970/combined-shapefile-1970*.

	% env TIMEZONES_1970=/where/you/put/timezones-1970/combined-shapefile-1970 \
		hypnotoad geo-timezone

Note that the instructions in [Geo::Location::TimeZoneFinder](https://metacpan.org/pod/Geo::Location::TimeZoneFinder) use a slightly different filename, but the advice is the same.

## Start the server

Run it as you would any other Mojolicious. `morbo` lets you develop since it reloads when files change:

	% morbo geo-timezone

Run it in production:

	% hypnotoad geo-timezone

## Query the server

There's one endpoint:

	% curl -s "http://127.0.0.1:3000/?date=2026-03-04+01:56&lat=44.00&lon=-83.789"

Mojolicious does not support semicolon parameter separators, so you must use the `&` separator, which means that a command-line call needs to quote the URL, or go the long way with `curl`:

	% curl -s -G \
		--data-urlencode lat=-83.789 \
		--data-urlencode lon=44.134 \
		--data-urlencode "date=2026-03-04 01:56" \
		http://127.0.0.1:3000

The query takes three parameters:

* lat - latitude in decimal
* lon - longitude in decimal
* date - as `YYYY-MM-DD HH::MM`

The date is that format because that's the one I need. You can fix that up yourself to do whatever you want.

## The response

You get JSON:

	% curl -s "http://127.0.0.1:3000/?date=2026-03-04+01:56&lat=44.00&lon=-93.789"
	{"abbr":"CST","date":"2026-03-04T01:56:00-06:00","dst":false,"epoch":1772610960,"geo":{"latitude":"44.00","longitude":"-93.789"},"input_date":"2026-03-04 01:56","names":["America\/Chicago"],"offset":"-06:00","url":"\/?date=2026-03-04+01%3A56&lat=44.00&lon=-93.789","version":"1.1"}

It's cleaner with `jq`:

	% curl -s "http://127.0.0.1:3000/?date=2026-03-04+01:56&lat=44.00&lon=-93.789" | jq -r .
	{
	  "abbr": "CST",
	  "date": "2026-03-04T01:56:00-06:00",
	  "dst": false,
	  "epoch": 1772610960,
	  "geo": {
		"latitude": "44.00",
		"longitude": "-93.789"
	  },
	  "input_date": "2026-03-04 01:56",
	  "names": [
		"America/Chicago"
	  ],
	  "offset": "-06:00",
	  "url": "/?date=2026-03-04+01%3A56&lat=44.00&lon=-93.789",
	  "version": "1.1"
	}
