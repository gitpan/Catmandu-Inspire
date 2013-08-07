package Catmandu::Fix::inspire;

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

1;