#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use DBIx::ParseDSN;

isa_ok( my $dsn = parse_dsn("dbi:Pg:database=foo"), "DBIx::ParseDSN::Default" );

is( $dsn->driver, "Pg", "parse_dsn; driver" );
is( $dsn->scheme, "dbi", "parse_dsn; scheme" );
is( $dsn->database, "foo", "parse_dsn; database" );

## some aliases:
is( $dsn->db, "foo", "parse_dsn; db alias" );
is( $dsn->dbname, "foo", "parse_dsn; dbname alias" );


done_testing;
