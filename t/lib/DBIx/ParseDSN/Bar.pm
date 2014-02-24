package
    DBIx::ParseDSN::Bar;

use Moose;
extends "DBIx::ParseDSN::Default";

sub i_am_also_a_custom_driver { return 1 }

1;
