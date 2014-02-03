#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Path::Tiny;
use File::Temp qw/tempfile/;

use_ok("DBIx::ParseDSN::Parser::Default");

## a plain SQLite dsn
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

    ## is_local and is_remote fails
    throws_ok {$dsn->is_local} qr/Cannot determine/, "is_local fails";
    throws_ok {$dsn->is_remote} qr/Cannot determine/, "is_remote fails";


}

## a SQLite dsn with driver attr and explicit db
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

    ## is_local and is_remote fails
    throws_ok {$dsn->is_local} qr/Cannot determine/, "is_local fails";
    throws_ok {$dsn->is_remote} qr/Cannot determine/, "is_remote fails";

}

## a SQLite dsn with a driver file that exists
{

    my ($fh,$filename) = tempfile;

    my $test_dsn = "dbi:SQLite:" . $filename;

    note( $test_dsn );

    ## check that dsn is required
    my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn);

    ## DBI's parse
    cmp_deeply(
        [$dsn->dsn_parts],
        [qw/dbi SQLite/, undef, undef, $filename ,],
        "DBI's parse_dsn gives expected results"
    );

    ## specifics
    is( $dsn->driver, "DBD::SQLite", "sqlite driver identified" );
    cmp_deeply( $dsn->driver_attr, undef, "attr" );
    is( $dsn->driver_dsn, $filename, "driver dsn" );

    ## parsed values
    is( $dsn->database, $filename, "parsed database" );

    ## is local since file exists
    ok( $dsn->is_local, "local since file exists" );
    ok( !$dsn->is_remote, "isn't remote since it's local" );

}

done_testing;
