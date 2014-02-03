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
        $test_dsn, "SQLite",
        { database => $filename },
        { database => $filename },
        undef, undef, $filename
    );

    ## is local since file exists
    ok( $dsn->is_local, "local since file exists" );
    ok( !$dsn->is_remote, "isn't remote since it's local" );

}

## Check a dsn test panel one by one

#     qw{
# dbi:ODBC:server=1.2.3.4;port=5678;database=DBNAME;driver=FreeTDS;tds_version=8.0
# dbi:Sybase:server=5.6.7.8:1234;database=DBNAME
# dbi:mysql:database=dbic_test;host=127.0.0.1
# dbi:Pg:database=dbic_test;host=127.0.0.1
# dbi:Firebird:dbname=/var/lib/firebird/2.5/data/dbic_test.fdb
# dbi:InterBase:dbname=/var/lib/firebird/2.5/data/dbic_test.fdb
# dbi:Oracle://localhost:1521/XE
# dbi:ADO:PROVIDER=sqlncli10;SERVER=tcp:172.24.2.10;MARSConnection=True;InitialCatalog=CIS;UID=cis_web;PWD=...;DataTypeCompatibility=80;
# dbi:ODBC:Driver=Firebird;Dbname=/var/lib/firebird/2.5/data/hlaghdb.fdb
# dbi:InterBase:db=/var/lib/firebird/2.5/data/hlaghdb.fdb
# dbi:Firebird:db=/var/lib/firebird/2.5/data/hlaghdb.fdb
#   };

note( "DSN test panel" );

test_dsn_basics(
    "dbi:ODBC:server=1.2.3.4;port=5678;database=DBNAME;driver=FreeTDS;tds_version=8.0",
    "ODBC",
    {
        host => "1.2.3.4", port => 5678, database => "DBNAME" },
    {
        server => "1.2.3.4",
        port => 5678,
        database => "DBNAME",
        driver => "FreeTDS",
        tds_version => "8.0",
    },
    undef, undef,
    "server=1.2.3.4;port=5678;database=DBNAME;driver=FreeTDS;tds_version=8.0"
);

my $dsn = test_dsn_basics(
    "dbi:Sybase:server=5.6.7.8:1234;database=DBNAME",
    "Sybase",
    { host => "5.6.7.8", port => 1234, database => "DBNAME" },
    {
        server => "5.6.7.8:1234",
        database => "DBNAME",
    },
    undef, undef,
    "server=5.6.7.8:1234;database=DBNAME"
);


done_testing;
