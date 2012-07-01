package Unit::Component::Foo;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::BindingDictionary;

use Unit::Component::Baz;

sub goo     { return $_[0]->{_goo}  }
sub set_goo { $_[0]->{_goo} = $_[1] }
sub banana     { return $_[0]->{_banana}  }
sub set_banana { $_[0]->{_banana} = $_[1] }

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->set_banana( $request->param( $self->node_id() ) );
    $self->SUPER::take_values_from_request( $request, $context );
}

sub bindings {
    my ( $self ) = @_;
    return Prospero::BindingDictionary->new({
        baz => {
            type => "Unit::Component::Baz",
            quux => q(banana),
        },
    });
}

1;