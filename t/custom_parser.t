#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;
use Test::Moose;

{
    package DBIx::ParseDSN::Parser::Custom;

    use Moose;
    extends "DBIx::ParseDSN::Parser::Default";

    sub names_for_database {
        return qw/bucket/;
    }

    sub is_local { return; }

}

my $dsn = DBIx::ParseDSN::Parser::Custom->new("dbi:SQLite:bucket=bar");

isa_ok( $dsn, "DBIx::ParseDSN::Parser::Default" );

is( $dsn->database, "bar", "custom database label" );
ok( $dsn->is_remote, "it is remote because it is not local" );

done_testing;
