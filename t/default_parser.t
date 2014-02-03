#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Test::Most;
use Test::FailWarnings;

use_ok("DBIx::ParseDSN::Parser::Default");

my $test_dsn = "dbi:SQLite:dbfile=foo.sqlite";

## check that dsn is required
isa_ok( my $dsn = DBIx::ParseDSN::Parser::Default->new($test_dsn),
        "DBIx::ParseDSN::Parser::Default");

done_testing;
