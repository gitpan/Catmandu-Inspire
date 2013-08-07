use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name => 'Catmandu::Inspire',
    dist_version => '0.15',
    license => 'perl',
    dist_author => [
        'Vitali Peil <vitali.peil at uni-bielefeld.de>'
    ],
    dist_version_from => 'lib/Catmandu/Inspire.pm',
    build_requires => {
        'Software::License' => 0,
        'Test::Exception' => 0,
        'Test::More' => 0,
    },
    requires => {
        'perl' => '5.10.1',
        'Catmandu' => '0.5004',
        'Furl' => '0.41',
        'XML::Simple' => '2.20'
    },
    add_to_cleanup => [qw(
        Catmandu-Inspire*
    )],
    create_makefile_pl => 'traditional',
    create_license => 1,
);

$builder->create_build_script;
