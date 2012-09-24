package Prospero::Plugin::TT2;

use strict;
use warnings;

use base qw( Prospero::Plugin );

use Prospero::Plugin::TT2::Component;
use Prospero::Plugin::TT2::Engine;
use Prospero::Plugin::TT2::Grammar;

use Data::Dumper;

__PACKAGE__->register_plugin(
    callbacks => {
        will_render => sub {
            my ( $component, $response, $context ) = @_;
            # print STDERR "->" x ( $component->render_state()->page_context_depth() - 1 );
            # print STDERR " " . $component."\n";
        },
    },
);

1;