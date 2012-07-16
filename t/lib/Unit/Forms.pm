package Unit::Forms;

use strict;

use base qw( Test::Class );

use Test::More;
use Data::Dumper;

use Prospero::Component;
use Prospero::Context;
use Prospero::RequestFrame;
use Prospero::Request::Offline;

use Prospero::Component::System::Components;

use Unit::Component::FormTest;

sub setup : Test( startup ) {
    my ( $self ) = @_;

    # load the config
    $self->{_context} = Prospero::Context->new({
        environment => {
            TT2_CONFIG => {
                INCLUDE_PATH => [ "share/templates/en", "t/templates", ],
                DEBUG => 1,
            },
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });
}

sub test_render : Tests {
    my ( $self ) = @_;

    my $c = Unit::Component::FormTest->new();
    my $output = $c->render_in_context( $self->{_context} );
    diag $output;
    ok( $output, "rendered content" );
}

1;