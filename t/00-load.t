#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

my $pkg;
my $pkg_fix;

BEGIN {
    $pkg     = 'Catmandu::Importer::Inspire';
    $pkg_fix = 'Catmandu::Fix::inspire_extract_id';
    use_ok $pkg;
    use_ok $pkg_fix;
}
require_ok $pkg;
require_ok $pkg_fix;

dies_ok { $pkg->new( fmt => 'endnote' ) } "die of missing arguments";
lives_ok { $pkg->new( doi => '10.1088/1126-6708/2009/03/112' ) } "I'm alive";
lives_ok { $pkg->new( id  => '811388' ) } "I'm alive";
lives_ok { $pkg->new( query => "hadronization" ) } "I'm alive";

my $fixer = Catmandu::Fix->new( fixes => ['inspire_extract_id()'] );

my $importer = $pkg->new(
    fmt => 'marc',
    doi => '10.1088/1126-6708/2009/03/112',
);

isa_ok( $importer, $pkg );
can_ok( $importer, 'each' );

my $importer2 = $pkg->new(
    fmt => 'marc',
    id  => '811388',
);

isa_ok( $importer2, $pkg );
can_ok( $importer2, 'each' );

my $f  = $fixer->fix($importer);
my $f2 = $fixer->fix($importer2);

my $data = {
    'url'  => 'http://inspirehep.net/record/811388',
    'id'   => '811388',
    'cern' => {
        'url' => 'http://cds.cern.ch/record/1156806',
        'id'  => '1156806'
    },
    'arxiv' => {
        'url' => 'http://arxiv.org/abs/0901.3094',
        'id'  => '0901.3094'
    },
    'doi' => '10.1088/1126-6708/2009/03/112',
};

is_deeply $f->first,  $data, "compare records";
is_deeply $f2->first, $data, "compare records";

done_testing;
