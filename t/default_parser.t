#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use File::Temp qw/tempfile/;

use t::lib::TestUtils;

use_ok("DBIx::ParseDSN::Parser::Default");

## no dsn causes error
throws_ok {DBIx::ParseDSN::Parser::Default->new}
    qr/\QAttribute (dsn) is required/,
    "dsn is required argument";

## a plain SQLite dsn
{

    my $test_dsn = "dbi:SQLite:foo.sqlite";

    my $dsn = test_dsn_basics($test_dsn,
                              "SQLite",
                              {database => "foo.sqlite"},
                              {database => "foo.sqlite"},
                              undef, undef,"foo.sqlite",
                          );

    ## is_local and is_remote fails
    throws_ok {$dsn->is_local} qr/Cannot determine/, "is_local fails";
    throws_ok {$dsn->is_remote} qr/Cannot determine/, "is_remote fails";

}

## a SQLite dsn with driver attr and explicit db
{

    my $test_dsn = "dbi:SQLite(foo=bar):dbname=foo.sqlite";

    my $dsn = test_dsn_basics(
        $test_dsn,"SQLite",
        { database => "foo.sqlite" },
        { dbname => "foo.sqlite" },
        "foo=bar", {foo=>"bar"}, "dbname=foo.sqlite"
    );

    ## is_local and is_remote fails
    throws_ok {$dsn->is_local} qr/Cannot determine/, "is_local fails";
    throws_ok {$dsn->is_remote} qr/Cannot determine/, "is_remote fails";

}

## a SQLite dsn with a driver file that exists
{

    my ($fh,$filename) = tempfile;

    my $test_dsn = "dbi:SQLite:" . $filename;

    my $dsn = test_dsn_basics(
        $test_dsn,"SQLite",
        { database => $filename },
        {},
        undef, undef, $filename
    );

    ## is local since file exists
    ok( $dsn->is_local, "local since file exists" );
    ok( !$dsn->is_remote, "isn't remote since it's local" );

}

done_testing;
