package Prospero::Component::System::Password;

use strict;
use base qw(
    Prospero::Component::System::TextField
);

use Prospero::PageResource;


sub required_page_resources {
    my ($self) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/Password.js"),
    ];
}

1;
