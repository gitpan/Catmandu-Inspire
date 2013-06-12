#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib qw(lib);
my $pkg;
BEGIN {
    $pkg = 'Catmandu::Importer::Inspire';
    use_ok $pkg;
}

require_ok $pkg;

done_testing 2;
