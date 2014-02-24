#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::FailWarnings;

use DBIx::ParseDSN::Default;
use t::lib::TestUtils;

isa_ok( my $dsn = DBIx::ParseDSN::Default->new("dbi:Pg:", 'user@bar'), "DBIx::ParseDSN::Default" );

is( $dsn->driver, "Pg", "one arg dsn; driver" );
is( $dsn->scheme, "dbi", "one arg dsn; scheme" );
is( $dsn->database, "bar", "bar arg dsn; database" );

done_testing;
