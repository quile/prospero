package Unit::Component::Foo;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::BindingDictionary;

sub bindings {
    my ( $self ) = @_;
    return Prospero::BindingDictionary->new({
        baz => {
            type => "Unit::Component::Baz",
        },
    });
}

1;