#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Path::Tiny;
use File::Temp qw/tempfile/;

use_ok("DBIx::ParseDSN::Parser::Default");

## no dsn causes error
throws_ok {DBIx::ParseDSN::Parser::Default->new}
    qr/\QAttribute (dsn) is required/,
    "dsn is required argument";

sub test_dsn_basics {

    my ($test_dsn,$driver,$attr,@parts) = @_;

    note( $test_dsn );

    my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn);

    ## DBI's parse
    cmp_deeply(
        [$dsn->dsn_parts],
        ["dbi", $driver, @parts ],
        "DBI's parse_dsn gives expected results"
    );

    ## driver
    is( $dsn->driver, "SQLite", "driver" );

    ## specifics
    is( $dsn->dbd_driver, "DBD::" . $driver, "sqlite driver identified" );
    cmp_deeply( $dsn->driver_attr, $parts[1], "attr" );
    is( $dsn->driver_dsn, $parts[2], "driver dsn" );

    ## parsed values
    is( $dsn->database, "foo.sqlite", "parsed database" );
    is( $dsn->host, undef, "host undef" );
    is( $dsn->port, undef, "port undef" );

    return $dsn;

}

## a plain SQLite dsn
{

    my $test_dsn = "dbi:SQLite:foo.sqlite";

    my $dsn = test_dsn_basics($test_dsn,
                              "SQLite",
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
        "foo=bar", {foo=>"bar"}, "dbname=foo.sqlite"
    );

    ## is_local and is_remote fails
    throws_ok {$dsn->is_local} qr/Cannot determine/, "is_local fails";
    throws_ok {$dsn->is_remote} qr/Cannot determine/, "is_remote fails";

}

done_testing
__END__


## a SQLite dsn with a driver file that exists
{

    my ($fh,$filename) = tempfile;

    my $test_dsn = "dbi:SQLite:" . $filename;

    note( $test_dsn );

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
    is( $dsn->host, undef, "host undef" );
    is( $dsn->port, undef, "port undef" );

    ## is local since file exists
    ok( $dsn->is_local, "local since file exists" );
    ok( !$dsn->is_remote, "isn't remote since it's local" );

}



done_testing;
