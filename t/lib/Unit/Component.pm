package Unit::Component;

use strict;

use base qw( Test::Class );

use Test::More;

use Prospero::Component;
use Prospero::Context;

use Unit::Component::Hello;

sub setup : Test( startup ) {
    my ( $self ) = @_;

    # load the config
    $self->{_context} = Prospero::Context->new({
        environment => {
            TT2_CONFIG => {
                INCLUDE_PATH => "t/templates",
                DEBUG => 1,
            },
        },
    });
}

sub test_render : Tests {
    my ( $self ) = @_;

    ok(1);
    my $c = Unit::Component::Hello->new();
    my $output = $c->render_in_context( $self->{_context} );
    diag $output;
    ok( $output, "rendered content" );
    ok( $output =~ /Hi!/, "text matches" );
    ok( $output =~ /bar/, "foo rendered" );
    ok( $output =~ /baz/, "bar rendered" );
}

1;