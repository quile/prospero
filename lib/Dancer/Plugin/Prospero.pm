package Dancer::Plugin::Prospero;

use strict;
use warnings;

use Dancer qw(:syntax);
use Dancer::Plugin;
use Dancer::Error;

use Prospero;
use Prospero::Request::Dancer;

# request's context
my $_context;
register prospero_context => sub { (@_ == 2) ? $_context = $_[1] : $_context };

my $_request;
register prospero_request => sub { (@_ == 2) ? $_request = $_[1] : $_request };

register prospero_page => sub {
    my ( $component_name ) = @_;

    debug "Instantiating $component_name";
    Dancer::ModuleLoader->load( $component_name );

    # and/or allow component namespaces
    return $component_name->new();
};

# Wrap an action with the rewinding and response generation
register prospero_handler => sub {
    my ( $component, $code ) = @_;

    $code ||= sub {};

    my $context = __PACKAGE__->prospero_context();

    # 1. rewind
    $component->rewind_request_in_context( __PACKAGE__->prospero_request(), __PACKAGE__->prospero_context() );

    # 2. call code
    my $response_component = undef;
    if ( ref( $code ) eq "CODE" ) {
        $response_component = $code->( $component, $context ) || $component;
    } else {
        debug "Action $code specified by name";
        if ( $component->can( $code ) ) {
            $response_component = $component->$code( $context ) || $component;
        } else {
            return send_error( "Action $code doesn't exist on $component", "404" );
        }
    }

    return $response_component->render_in_context( __PACKAGE__->prospero_context() );
};

# TODO:kd - don't run this for static resources
hook before => sub {
    my $r = request;

    # TODO:kd - skip if requesting something other than a routed URL
    return if ( $r->path() =~ /if-static/ );

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
    my $response = shift;
    unless ( __PACKAGE__->prospero_context() ) {
        return $response;
    }

    my $frame = __PACKAGE__->prospero_context()->outgoing_request_frame();
    unless ( $frame && scalar keys %{ $frame->rendered_components } ) {
        return $response;
    }

    debug 'Ending Prospero request... serialising request frame';
    my $frames = session('frames') || [];
    my $frame_offset = session('frame_offset') || 0;
    my $frame_number = session('frame_number') || 0;

    # if there's an outgoing frame, then Prospero generated it during
    # rendering, so push it into the session frame list, truncating the
    # list if it's grown too long.

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

    #debug "Session, frame number $frame_number, offset $frame_offset, frames ";
    #debug $frames;
    return $response;
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

=head1 SYNOPSIS


  use Dancer::Plugin::Prospero;


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

=head2 prospero_context

This will return the Prospero context object that the Dancer plugin
creates automatically from an incoming request.

=head2 prospero_request

Get the Prospero version of the incoming request.  This is created
automatically by the plugin.

=head2 prospero_page


  my $page = prospero_page( "My::Page::Class" );

This instantiates a Prospero component, and configures it to work
under Dancer.   You will generally use this at the beginning
of one of your actions.  It only takes a single argument,
which is the name of the class.

=head2 prospero_handler

This abstracts the nuts and bolts of the Prospero request-response
loop away from you and allows you to just write the code that responds
to web requests.

  prospero_handler $page => sub {
      my ( $self ) = @_;
      ...
      return prospero_page( "Some::Other::Page" );
  }

You can specify the name of a method on $page as the second argument
instead of a code reference:


  prospero_handler $page => "handle_submit";

which will invoke the method $page->handle_submit() with the
correct arguments.  This allows you to build a component's
handling logic into its class.

A very simple example might be something like:

  get '/some/page/show' => sub {
      my $page = prospero_page( "Some::Page" );

      # do some stuff with your new instance
      # ...

      # return it to the browser
      prospero_handler $page;
  };

  get '/some/page/submit' => sub {
      my $page = prospero_page( "Some::Page" );

      prospero_handler $page => sub {
          my ( $self ) = @_;

          # Page has been submitted and all data unwound and
          # your objects have been updated.

          # You can so fancy validation, or save your objects, or throw an
          # error, or whatever.  This is your action.

          # Lastly, you can either instantiate and return a totally new page,
          # or you can return undef, which will render $page (with all its
          # values intact)
      };
  };



=head1 DEPENDENCY

This module depends on L<Prospero> and L<Dancer>.

=head1 AUTHOR

Kyle Dawkins, info@kyledawkins.com

=head1 COPYRIGHT

This module is copyright (c) 2012 Kyle Dawkins <info@kyledawkins.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
