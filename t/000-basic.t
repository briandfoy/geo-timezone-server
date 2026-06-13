use v5.42;

use Test::More;
use Test::Mojo;

my $script = Mojo::File->new(__FILE__)->dirname->dirname->sibling('geo-timezone');
ok -e $script, "script exists <$script>";
my $t = Test::Mojo->new($script);

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
