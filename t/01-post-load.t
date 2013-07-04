#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

my $pkg;
BEGIN {
  $pkg = 'Catmandu::Importer::Inspire';
  use_ok($pkg);
}

my $importer_id = Catmandu::Importer::Inspire->new(id => "1192938", format => "marc");
isa_ok($importer_id, $pkg);
can_ok($importer_id, 'each');

my $importer_query = Catmandu::Importer::Inspire->new(format => "dc", doi => "10.1103/PhysRevLett.105.026802");
isa_ok($importer_id, $pkg);
can_ok($importer_id, 'each');

done_testing 5;