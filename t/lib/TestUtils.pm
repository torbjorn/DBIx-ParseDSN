package TestUtils;

use utf8::all;
use strict;
use warnings;
use autodie;

sub sample_dsns {

    qw{
dbi:ODBC:server=$IP;port=$PORT;database=$DBNAME;driver=FreeTDS;tds_version=8.0
dbi:Sybase:server=$IP:$PORT;database=$DBNAME
dbi:mysql:database=dbic_test;host=127.0.0.1
dbi:Pg:database=dbic_test;host=127.0.0.1
dbi:Firebird:dbname=/var/lib/firebird/2.5/data/dbic_test.fdb
dbi:InterBase:dbname=/var/lib/firebird/2.5/data/dbic_test.fdb
dbi:Oracle://localhost:1521/XE
dbi:ADO:PROVIDER=sqlncli10;SERVER=tcp:172.24.2.10;MARSConnection=True;InitialCatalog=CIS;UID=cis_web;PWD=...;DataTypeCompatibility=80;
dbi:ODBC:Driver=Firebird;Dbname=/var/lib/firebird/2.5/data/hlaghdb.fdb
dbi:InterBase:db=/var/lib/firebird/2.5/data/hlaghdb.fdb
dbi:Firebird:db=/var/lib/firebird/2.5/data/hlaghdb.fdb
  };

}

1;
