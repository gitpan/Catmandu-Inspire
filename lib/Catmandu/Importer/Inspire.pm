package Catmandu::Importer::Inspire;

use strict;
use warnings;
use Catmandu::Sane;
use Moo;
use Furl;
use XML::LibXML::Simple qw(XMLin);

with 'Catmandu::Importer';

# INFO:
# http://inspirehep.net/
# at the moment no api available


# Constants. -------------------------------------------------------------------

use constant BASE_URL => 'http://inspirehep.net/';
use constant DEFAULT_FORMAT => 'endnote';

# Properties. ------------------------------------------------------------------

# required.
has base => (is => 'ro', default => sub { return BASE_URL; });
has format => (is => 'ro', default => sub { return DEFAULT_FORMAT; });
has doi => (is => 'ro');
has id => (is => 'ro');

# Mapping
my %FORMAT_MAPPING = (
    'endnote' => 'xe',
    'nlm' => 'xn',
    'marc' => 'xm',
    'dc' => 'xd',
    );
# Internal Methods. ------------------------------------------------------------

# Internal: HTTP GET something.
#
# $url - the url.
#
# Returns the raw response object.
sub _request {
  my ($self, $url) = @_;

  my $furl = Furl->new(
    agent => 'Mozilla/5.0',
    timeout => 10
  );

  my $res = $furl->get($url);
  die $res->status_line unless $res->is_success;

  return $res;
}

# Internal: Converts XML to a perl hash.
#
# $in - the raw XML input.
#
# Returns a hash representation of the given XML.
sub _hashify {
  my ($self, $in) = @_;

  my $xs = XML::LibXML::Simple->new();
  my $out = $xs->XMLin(
	  $in, 
  );

  return $out;
}

# Internal: Makes a call to the Inspire record
#
# Returns the XML response body.
sub _call {
  my ($self) = @_;

  # construct the url
  my $url = $self->base;
  #my $query = $self->query || '';
  #my $id = $self->id || '';
  my $fmt = $FORMAT_MAPPING{$self->format};
  if ($self->doi) {
    #$url .= "search?&action_search=Suchen&of=" . $fmt . "p=" . $query;
    $url .= 'search?p=doi%3A'. $self->doi .'&of='. $fmt .'&action_search=Suchen';
  } elsif ($self->id) {
    $url .= 'record/'. $self->id . '/export/' . $fmt;
  } else {
    Catmandu::BadVal->throw("Either ID or DOI is required.");
  }

  # http get the url.
  my $res = $self->_request($url);

  # return the response body.
  return $res->{content};
}

# Internal: gets the next set of results.
#
# Returns a hash representation of the resultset.
sub _get_record {
  my ($self) = @_;
  
  # fetch the xml response and hashify it.
  my $xml = $self->_call;
  my $hash = $self->_hashify($xml);

  # return a reference to a hash.
  return $hash;
}

# Public Methods. --------------------------------------------------------------

sub generator {
  my ($self) = @_;
  my $return = 1;

  return sub {
	# hack to make iterator stop.
	if ($return) {
		$return = 0;
		return $self->_get_record;
	}
	return undef;
  };
}


# PerlDoc. ---------------------------------------------------------------------

=head1 NAME

  Catmandu::Importer::Inspire - Package that imports Inspire data.

=head1 SYNOPSIS

  use Catmandu::Importer::Inspire;

  my %attrs = (
    id => '1203476',
    format => 'endnote',
  );

  OR

  my %attrs = (
    query => 'doi:10.1103/PhysRevD.82.112004'
    format => 'marc',
  );

  my $importer = Catmandu::Importer::Inspire->new(%attrs);

  my $n = $importer->each(sub {
    my $hashref = $_[0];
    # ...
  });

=cut

=head1 SEE ALSO

L<Catmandu::Iterable>

=cut

1;
