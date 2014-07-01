package Catmandu::Importer::Inspire;

use Catmandu::Sane;
use XML::LibXML::Simple qw(XMLin);
use Furl;
use Moo;

with 'Catmandu::Importer';

use constant BASE_URL       => 'http://inspirehep.net/';
use constant DEFAULT_FORMAT => 'endnote';

has base => ( is => 'ro', default => sub { return BASE_URL; } );
has fmt  => ( is => 'ro', default => sub { return DEFAULT_FORMAT; } );
has doi  => ( is => 'ro' );
has query => ( is => 'ro' );
has id    => ( is => 'ro' );
has limit => ( is => 'ro', default => sub { return 25; } );

my %FORMAT_MAPPING = (
    'endnote' => 'xe',
    'nlm'     => 'xn',
    'marc'    => 'xm',
    'dc'      => 'xd',
);

sub BUILD {
    my $self = shift;

    Catmandu::BadVal->throw("Either ID or DOI or a QUERY is required.")
        unless $self->id || $self->doi || $self->query;
}

sub _request {
    my ( $self, $url ) = @_;

    my $furl = Furl->new(
        agent   => 'Mozilla/5.0',
        timeout => 10
    );

    my $res = $furl->get($url);
    die $res->status_line unless $res->is_success;

    return $res;
}

sub _hashify {
    my ( $self, $in ) = @_;

    my $xs  = XML::LibXML::Simple->new();
    my $out = $xs->XMLin( $in, );

    return $out;
}

sub _call {
    my ($self) = @_;

    my $url = $self->base;
    my $fmt = $FORMAT_MAPPING{ $self->fmt };

    if ( $self->id ) {
        $url .= 'record/' . $self->id . '/export/' . $fmt;
    }
    else {
        $url .= 'search?p=';
        ( $self->doi )
            ? ( $url .= 'doi%3A' . $self->doi )
            : ( $url .= $self->query );

        $url .= '&of=' . $fmt;
        $url .= '&rg=' . $self->limit;
        $url .= '&action_search=Suchen';
    }

    my $res = $self->_request($url);

    return $res->{content};
}

sub _get_record {
    my ($self) = @_;

    my $xml  = $self->_call;
    my $hash = $self->_hashify($xml);

    return $hash;
}

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

=head1 NAME

  Catmandu::Importer::Inspire - Package that imports Inspire data http://inspirehep.net/.

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

L<Catmandu::Iterable>, L<Catmandu::ArXiv>

=cut

1;
