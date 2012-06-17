package Unit::Component::Bar;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::BindingDictionary;

sub bindings {
    my ( $self ) = @_;
    return Prospero::BindingDictionary->new({
        content => {
            type => "CONTENT",
        },
    });
}

1;