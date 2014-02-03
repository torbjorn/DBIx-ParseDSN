#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok("DBIx::ParseDSN::Parser::Default");

my $test_dsn = "dbi:SQLite(foo=bar):foo.sqlite";

## check that dsn is required
isa_ok( my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn),
        "DBIx::ParseDSN::Parser::Default");

## DBI's parse
cmp_deeply(
    [$dsn->dsn_parts],
    [qw/dbi SQLite foo=bar/, {foo=>"bar"}, "foo.sqlite",],
    "DBI's parse_dsn gives expected results"
);

## specifics
is( $dsn->driver, "DBD::SQLite", "sqlite driver identified" );
cmp_deeply( $dsn->driver_attr, {foo=>"bar"}, "attr" );
is( $dsn->driver_dsn, "foo.sqlite", "driver dsn" );

## parsed values
is( $dsn->database, "foo.sqlite", "parsed database" );

done_testing;
