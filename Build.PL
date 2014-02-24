use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'DBIx::ParseDSN',
    license             => 'artistic',
    dist_author         => 'Torbjørn Lindahl <torbjorn.lindahl@gmail.com>',
    dist_version_from   => 'lib/DBIx/ParseDSN.pm',
    requires => {
        'DBI'                       => '1.63',
        'Locale::Maketext::Lexicon' => '0.96',
        'Moose'                     => '2.1005',
        'Test::FailWarnings'        => '0.008',
        'Test::Moose'               => '2.1005',
        'Test::Most'                => '0.31',
        'Test::Perl::Critic'        => '1.02',
        'Test::Pod'                 => '1.48',
        'Test::Pod::Coverage'       => '1.08',
        'URI'                       => '1.60',
        'utf8::all'                 => '0.011',
        'Class::Load'               => '0.20',
        'Module::Load::Conditional' => '0.54',
        'Moose'                     => '2.1005',
        'MooseX::Aliases'           => '0.10',
    },
    add_to_cleanup      => [ 'DBIx-ParseDSN-*' ],
);

$builder->create_build_script();
