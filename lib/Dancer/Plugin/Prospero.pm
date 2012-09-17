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

    # push the frame number into the Prospero world
    my $current_frame_number = session( 'frame_number' ) || 0;
    __PACKAGE__->prospero_context()->set_frame_number( $current_frame_number );

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

1;

__END__

=pod

=head1 NAME

Dancer::Plugin::Prospero - Use Prospero within a Dancer application

=head1 DESCRIPTION

This module provides the glue between the Prospero system and Dancer.
It is implemented as C<before> and C<after> hooks that run when
a web request is received and immediately before a response is
returned.  Those hooks initialise the context for a Prospero
request, and take care of setting up the request frames that make
the Prospero gearing work.

=head1 CONFIGURATION

You must C<use> the module within your application.  You must also
specify one of the session modules. (Note: Unfortunately, it will not
--currently-- work with the cookie-based session, because the C<after>
hook runs too late in the process to update the session cookie.)

=head1 METHODS

There are no methods that you call directly.  If you

use Dancer::Plugin::Prospero;

then the required hooks will automatically be installed and Prospero's stateful
machinery will be in place.

=head1 DEPENDENCY

This module depends on L<Prospero> and L<Dancer>.

=head1 AUTHOR

Kyle Dawkins, info@kyledawkins.com

=head1 COPYRIGHT

This module is copyright (c) 2012 Kyle Dawkins <info@kyledawkins.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
