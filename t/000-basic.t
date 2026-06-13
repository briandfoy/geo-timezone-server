use v5.42;

use Test::More;
use Test::Mojo;

my $script = Mojo::File->new(__FILE__)->dirname->dirname->sibling('geo-timezone');
ok -e $script, "script exists <$script>";
my $t = Test::Mojo->new($script);


subtest 'bad requests' => sub {
	my $GOOD_DATE = '2026-05-31 14:12';
	my $GOOD_LAT  = '45.123';
	my $GOOD_LONG = '-73.543';

	my $BAD_DATE  = '2026-05-32 14:12';
	my $BAD_LAT   = '95.456';
	my $BAD_LONG  = '200.123';

	subtest 'no params' => sub {
		my $q = { };
		$t->get_ok( '/' )->status_is(400);
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};

	subtest 'just good date' => sub {
		my $q = { date => $GOOD_DATE };
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};

	subtest 'just bad date' => sub {
		my $q = { date => $BAD_DATE };
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};

	subtest 'bad lat, good long, good date' => sub {
		my $q = { lat => $BAD_LAT, lon => $GOOD_LONG, date => $GOOD_DATE };
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};

	subtest 'good lat, bad long, good date' => sub {
		my $q = { lat => $GOOD_LAT, lon => $BAD_LONG, date => $GOOD_DATE };
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};

	subtest 'good lat, good long, bad date' => sub {
		my $q = { lat => $GOOD_LAT, lon => $GOOD_LONG, date => $BAD_DATE };
		$t->get_ok( '/' => form => $q )->status_is(400)
			->json_has('/errors');
		};
	};

subtest 'New York' => sub {
	my $query = {
		lat => '44.00',
		lon => '-73.67',
		};

	subtest 'New York (not DST)' => sub {
		my $time = "12:45";
		my $q = { $query->%*, date => '2026-03-04 ' . $time };
		$t->get_ok( '/' => form => $q)->status_is('200')
			->json_is( '/dst'    => 0         )
			->json_is( '/offset' => '-05:00'  )
			->json_like( '/date' => qr/\Q$time\E/ )
		} or diag $t->tx->req->to_string;

	subtest 'New York (DST)' => sub {
		my $time = "09:12";
		my $q = { $query->%*, date => '2026-06-05 ' . $time };
		$t->get_ok( '/' => form => $q)->status_is('200')
			->json_is( '/dst' => true )
			->json_is( '/offset' => '-04:00' )
			->json_like( '/date' => qr/\Q$time\E/ )
		};
	};

done_testing();
