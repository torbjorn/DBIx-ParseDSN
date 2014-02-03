package DBIx::ParseDSN::Default;

use utf8::all;
use strict;
use autodie;
use warnings;
use Carp qw< carp croak confess cluck >;
use DBI; # will use parse_dsn
use URI;

use version; our $VERSION = qv('0.0.1');

use Moose;

with( 'MooseX::OneArgNew' => {
    type => 'Str',
    init_arg => 'dsn',
});

has dsn => ( isa => "Str", is => "ro", required => 1 );

has database => ( isa => "Str", is => "rw" );
has host     => ( isa => "Str", is => "rw" );
has port     => ( isa => "Int", is => "rw" );
has driver   => ( isa => "Str", is => "rw" );
has scheme   => ( isa => "Str", is => "rw", default => "dbi" );

has attr => (
    isa => "HashRef",
    traits => ["Hash"],
    is => "ro",
    default => sub {{}},
    handles => {
        set_attr => "set",
        get_attr => "get",
        delete_attr => "delete",
        attributes => "elements",
    }
);

around host => sub {

    my $orig = shift;
    my $self = shift;

    return $self->$orig unless my ($host) = @_;

    $host =~ s/^tcp://;

    if ( $host =~ s/:(\d+)// ) {
        $self->port($1);
    }

    return $self->$orig($host);

};

sub names_for_database {
    return (
        qw/database dbname namd db/,

        "file name", "initialcatalog", ## from ADO, but generic
                                        ## enough to allow in this
                                        ## module

        );
}
sub names_for_host {
    return qw/host hostname server/;
}
sub names_for_port {
    return qw/port/;
}
sub known_attribute_hash {

    my $self = shift;
    my %h;

    my @db_names = map { lc $_ } $self->names_for_database;
    @h{@db_names} = ("database") x @db_names;

    my @h_names = map { lc $_ } $self->names_for_host;
    @h{@h_names} = ("host") x @h_names;

    my @p_names = map { lc $_ } $self->names_for_port;
    @h{@p_names} = ("port") x @p_names;

    return %h;

}

sub dsn_parts {
    my $self = shift;
    return DBI->parse_dsn( $self->dsn );
}

sub dbd_driver {
    my $self = shift;
    my $driver = "DBD::" . $self->driver;
    return $driver;
}
sub driver_attr {

    my $self = shift;
    my ( $scheme, $driver, $attr, $attr_hash, $dsn ) = $self->dsn_parts;

    return $attr_hash;

}
sub driver_dsn {
    my $self = shift;
    return ($self->dsn_parts)[4];
}

sub is_remote {
    my $self = shift;
    return not $self->is_local
}
sub is_local {
    my $self = shift;

    ## not much the default can do. if database exists as a file we
    ## guess its a file based database and hence local
    if ( defined $self->host and
                 (
                 lc $self->host eq "localhost" or
                    $self->host eq "127.0.0.1"
                 )
         ) {
        return 1;
    }
    elsif ( -f $self->database ) {
        return 1;
    }

    confess "Cannot determine if db is local";

}

sub parse {

    ## look for the following in the driver dsn:
    ## 1: database: database dbname name db
    ## 2: host:     hostname host server
    ## 3: port:     port

    ## Assumes ";"-separated parameters in driver dsn
    ## If driver dsn is one argument, its assumed to be the database

    my $self = shift;

    $self->driver( ($self->dsn_parts)[1] );

    my @pairs = split /;/, $self->driver_dsn;

    my %known_attr = $self->known_attribute_hash;

    for (@pairs) {

        my($k,$v) = split /=/, $_, 2;

        ## a //foo:xyz/bar type of uri, like Oracle
        if ( $k =~ m|^//.+/.+| and not defined $v and @pairs == 1 ) {

            ## For this we offer something that works with oracle
            my $u = URI->new;
            $u->opaque($k);

            my @p = $u->path_segments;

            ## 2nd part of path is database
            if ( $p[1] ) {
                $self->database($p[1]);
            };

            ## host should be ok
            if ( my $host = $u->authority ) {

                ## might contain port
                if ( $host =~ s/:(\d+)// ) {
                    $self->port($1);
                }

                $self->host( $host );

            }

        }
        elsif (not defined $v and @pairs == 1) {
            $self->database($k);
        }

        if ( my $known_attr = $known_attr{lc $k} ) {
            $self->$known_attr( $v );
        }

        $self->set_attr($k, $v);

    }

}

sub BUILD {};

after BUILD => sub {
    my $self = shift;
    $self->parse;
};

1; # Magic true value required at end of module
__END__

=encoding utf8

=head1 NAME

DBIx::ParseDSN::Parser::Default - [One line description of module's purpose here]


=head1 VERSION

This document describes DBIx::ParseDSN::Parser::Default version 0.0.1


=head1 SYNOPSIS

    use DBIx::ParseDSN::Parser::Default;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE

=head2 parse( $dsn )

Parse with default rules

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

DBIx::ParseDSN::Parser::Default requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-bug-dbix-parsedsn::parser::default@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SEE ALSO

L<Some::Other::Module>,
L<Also::Anoter::Module>

=head1 AUTHOR

Torbjørn Lindahl  C<< <torbjorn.lindahl@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, Torbjørn Lindahl C<< <torbjorn.lindahl@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
