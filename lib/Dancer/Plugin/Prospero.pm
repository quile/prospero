package Dancer::Plugin::Prospero;

use strict;
use warnings;

use Dancer qw(:syntax);
use Dancer::Plugin;

use Prospero;
use Prospero::Request::Dancer;

# request's context
my $_context;
register prospero_context => sub { (@_ == 2) ? $_context = $_[1] : $_context };

my $_request;
register prospero_request => sub { (@_ == 2) ? $_request = $_[1] : $_request };

hook before => sub {
    my $r = request;
    debug 'Starting Prospero request...';

    # build a context:
    __PACKAGE__->prospero_context( __PACKAGE__->_new_context() );
    __PACKAGE__->prospero_request( Prospero::Request::Dancer->new($r) );

    #debug __PACKAGE__->prospero_context();

    # get the last request frame
    my $frames = session( 'frames' ) || [];
    my $last_request_frame = $frames->[0];
    if ( $last_request_frame ) {
        __PACKAGE__->prospero_context()->set_incoming_request_frame( $last_request_frame );
    }
};

hook after => sub {
    debug 'Ending Prospero request... serialising request frame';
    my $frames = session('frames') || [];
    if ( scalar @$frames > ( plugin_setting()->{maximum_request_frames} || 6 ) ) {
        shift @$frames;
    }
    my $frame = __PACKAGE__->prospero_context()->outgoing_request_frame();
    push @$frames, $frame if $frame;
    session 'frames' => $frames;
    debug 'Session frames: ';
    debug $frames;
};



sub _new_context {
    my ( $class ) = @_;
    my $engine = Dancer::Engine->engine("template")->_engine();
    return Prospero::Context->new({
        environment => {
            _TT2 => $engine,
        },
        outgoing_request_frame => Prospero::RequestFrame->new(),
    });
}

register_plugin;

1;