package Prospero::Component::System::Text;

use strict;
use base qw(
    Prospero::Component::System::TextField
);

use Prospero::PageResource;


sub required_page_resources {
    my ($self) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/TextField.js"),
    ];
}

sub rows     { return $_[0]->{_rows}  }
sub set_rows { $_[0]->{_rows} = $_[1] }
sub columns     { return $_[0]->{_columns}  }
sub set_columns { $_[0]->{_columns} = $_[1] }

1;