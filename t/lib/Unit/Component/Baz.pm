package Unit::Component::Baz;

use strict;
use warnings;
use base qw( Prospero::Plugin::TT2::Component );

use Prospero::PageResource;

sub quux     { return $_[0]->{_quux}  }
sub set_quux { $_[0]->{_quux} = $_[1] }

sub required_page_resources {
    return [
        Prospero::PageResource->javascript( "/foo/bar/bananas.js" ),
        Prospero::PageResource->javascript( "/foo/bar/papayas.js" ),
    ];
}

1;