package Prospero::Adaptor::Dancer;

use strict;
use warnings;

use Dancer::Engine qw();
use Dancer::Template::Prospero qw();

use Data::Dumper;

# TODO:kd - this will probably move into a Dancer plugin

sub context_from_request {
    my ( $class, $request ) = @_;

    my $engine = Dancer::Engine->engine("template")->_engine();
    return Prospero::Context->new({
        environment => {
            _TT2 => $engine,
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });
}

1;