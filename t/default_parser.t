#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok("DBIx::ParseDSN::Parser::Default");

## a plain dsn
{

    my $test_dsn = "dbi:SQLite:foo.sqlite";

    note( $test_dsn );

    ## check that dsn is required
    my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn);

    ## DBI's parse
    cmp_deeply(
        [$dsn->dsn_parts],
        [qw/dbi SQLite/, undef, undef, "foo.sqlite",],
        "DBI's parse_dsn gives expected results"
    );

    ## specifics
    is( $dsn->driver, "DBD::SQLite", "sqlite driver identified" );
    cmp_deeply( $dsn->driver_attr, undef, "attr" );
    is( $dsn->driver_dsn, "foo.sqlite", "driver dsn" );

    ## parsed values
    is( $dsn->database, "foo.sqlite", "parsed database" );

}

{

    my $test_dsn = "dbi:SQLite(foo=bar):dbname=foo.sqlite";

    note( $test_dsn );

    ## check that dsn is required
    my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn);

    ## DBI's parse
    cmp_deeply(
        [$dsn->dsn_parts],
        [qw/dbi SQLite/, "foo=bar", {foo=>"bar"}, "dbname=foo.sqlite",],
        "DBI's parse_dsn gives expected results"
    );

    ## specifics
    is( $dsn->driver, "DBD::SQLite", "sqlite driver identified" );
    cmp_deeply( $dsn->driver_attr, {foo=>"bar"}, "attr" );
    is( $dsn->driver_dsn, "dbname=foo.sqlite", "driver dsn" );

    ## parsed values
    is( $dsn->database, "foo.sqlite", "parsed database" );

}



done_testing;
