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

# TODO:kd - don't run this for static resources
hook before => sub {
    my $r = request;
    debug 'Starting Prospero request...';

    # build a context:
    __PACKAGE__->prospero_context( __PACKAGE__->_new_context() );
    __PACKAGE__->prospero_request( Prospero::Request::Dancer->new($r) );

    #debug __PACKAGE__->prospero_context();

    # push the frame number into the Prospero world
    my $current_frame_number = session( 'frame_number' ) || 0;
    __PACKAGE__->prospero_context()->set_frame_number( $current_frame_number );

    #debug session('frame_offset');
    #debug session('frame_number');

    my $incoming_frame_number = param( "prospero-frame-number" );

    if ( $incoming_frame_number ) {
        # get the correct request frame
        my $frames = session( 'frames' ) || [];

        my $frame_offset = session( 'frame_offset' ) || 0;
        my $last_request_frame = $frames->[ $incoming_frame_number - $frame_offset ];
        if ( $last_request_frame ) {
            __PACKAGE__->prospero_context()->set_incoming_request_frame( $last_request_frame );
        }
    }
};

hook after  => sub {
    debug 'Ending Prospero request... serialising request frame';
    my $frames = session('frames') || [];
    my $frame_offset = session('frame_offset') || 0;
    my $frame_number = session('frame_number') || 0;

    # if there's an outgoing frame, then Prospero generated it during
    # rendering, so push it into the session frame list, truncating the
    # list if it's grown too long.

    my $frame = __PACKAGE__->prospero_context()->outgoing_request_frame();
    if ( $frame ) {
        push @$frames, $frame;

        if ( scalar @$frames > ( plugin_setting()->{maximum_request_frames} || 6 ) ) {
            shift @$frames;
            $frame_offset += 1;
        }
    }

    # store housekeeping in the session

    $frame_number++;
    session( 'frames' => $frames );
    session( 'frame_offset' => $frame_offset );
    session( 'frame_number' => $frame_number );

    debug "Session, frame number $frame_number, offset $frame_offset, frames ";
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

# TODO:kd - when documenting, mention that the cookie-based sessions are not (yet) supported.

1;