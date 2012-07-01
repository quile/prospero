package Unit::Component::Baz;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::PageResource;

sub required_page_resources {
    return [
        Prospero::PageResource->javascript( "/foo/bar/bananas.js" ),
        Prospero::PageResource->javascript( "/foo/bar/papayas.js" ),
    ];
}

1;