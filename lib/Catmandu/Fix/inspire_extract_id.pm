package Catmandu::Fix::inspire_extract_id;

use Catmandu::Sane;
use Moo;

sub fix {
  my ( $self, $pub ) = @_;

  my $rec;

  if ( $pub && $pub->{record} ) {
    foreach ( @{ $pub->{record}->{controlfield} } ) {
      if ( $_->{tag} eq "001" and $_->{content} ) {
        $rec->{id}  = $_->{content};
        $rec->{url} = "http://inspirehep.net/record/" . $_->{content};
      }
    }


    foreach my $datafield ( @{ $pub->{record}->{datafield} } ) {
      if ($datafield->{tag} eq "024") {
        foreach my $sf ( @{ $datafield->{subfield} } ) {
          if ( $sf->{code} eq 'a' ) {
            $rec->{doi} = $sf->{content};
          }
        }
      }
      next unless $datafield->{tag} eq "035";
      if ( ref $datafield->{subfield} eq "ARRAY" ) {
        my $temphash;
        foreach my $sf ( @{ $datafield->{subfield} } ) {
          if ( $sf->{code} eq '9' ) {
            $temphash->{type} = $sf->{content};
          }
          elsif ( $sf->{code} eq 'z' or $sf->{code} eq 'a' ) {
            $temphash->{value} = $sf->{content};
          }
        }

        if ( $temphash->{type}
          && $temphash->{type} eq "arXiv"
          && $temphash->{value} )
        {
          $temphash->{value} =~ s/oai\:arXiv.org\:(.*)/$1/g;
          $rec->{arxiv}->{id} = $temphash->{value} if $temphash->{value};
          $rec->{arxiv}->{url} = "http://arxiv.org/abs/" . $temphash->{value}
            if $temphash->{value};
        }
        elsif ( $temphash->{type} and $temphash->{type} eq "CDS" ) {
          $rec->{cern}->{id} = $temphash->{value} if $temphash->{value};
          $rec->{cern}->{url} =
            "http://cds.cern.ch/record/" . $temphash->{value}
            if $temphash->{value};
        }
      }
      else {
        my $temphash;
        if ( $datafield->{subfield}->{code} eq '9' ) {
          $temphash->{type} = $datafield->{subfield}->{content};
        }
        elsif ( $datafield->{subfield}->{code} eq 'z'
          or $datafield->{subfield}->{code} eq 'a' )
        {
          $temphash->{value} = $datafield->{subfield}->{content};
        }

        if (  $temphash->{type}
          and $temphash->{type} eq "arXiv"
          and $temphash->{value} )
        {
          $temphash->{value} =~ s/oai\:arXiv.org\:(.*)/$1/g;
          $rec->{arxiv}->{id} = $temphash->{value} if $temphash->{value};
          $rec->{arxiv}->{url} = "http://arxiv.org/abs/" . $temphash->{value}
            if $temphash->{value};
        }
        elsif ( $temphash->{type} and $temphash->{type} eq "CDS" ) {
          $rec->{cern}->{id} = $temphash->{value} if $temphash->{value};
          $rec->{cern}->{url} =
            "http://cds.cern.ch/record/" . $temphash->{value}
            if $temphash->{value};
        }
      }
    }
  }

  return $rec;

}

=head1 NAME

Catmandu::Fix::inspire - a Catmandu Fix, which filters appropriate fields, e.g doi, arxivId, etc.

=head1 SYNOPSIS

  use Catmandu::Importer::Inspire;
  use Catmandu::Fix::inspire;

  my $fixer = Catmandu::Fix->new(fixes => ['inspire()']);
  
  # get data via doi
  my $importer = Catmandu::Importer::Inspire->new(format => 'marc', doi => "10.1088/1126-6708/2009/03/112");
  # or via inspire id
  #my $importer = Catmandu::Importer::Inspire->new(format => 'marc', id => "811388");
  
  # gives an interable object $newRec;
  my $newRec = $fixer->fix($importer);
  use Data::Dumper;
  print Dumper $newRec->first;

=cut

1;
