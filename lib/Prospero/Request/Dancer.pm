package Prospero::Request::Dancer;

use Dancer qw( :syntax );

use Prospero::Utility qw( array_from_object );

use base qw( Prospero::Request );

sub new {
    my ( $class, $request ) = @_;
    my $self = bless {
        '_request'  => $request,
    }, $class;

    my %params = $request->params();
    $self->{_params} = \%params;
    # my %cookies = $request->cookies();
    # $self->{_cookies} = \%cookies;
    return $self;
}

sub dancer_request {
    my ( $self ) = @_;
    return $self->{_request};
}

sub uri {
    my $self = shift;
    return $self->{_request}->path();
}

sub header_for_key {
    my ( $self, $key ) = @_;
    my $headers = $self->{_request}->header( $key );
}

sub param {
    my ( $self, $key, $value ) = @_;
    if ( $key ) {
        if ( $value ) {
            $self->unimplemented();
        } else {
            if ( wantarray() ) {
                my $params = array_from_object( $self->{_params}->{ $key } );
                return @$params;
            } else {
                return $self->{_params}->{ $key };
            }
        }
    } else {
        return keys %{ $self->{_params} };
    }
    return;
}

sub cookie_value_for_key {
    my ( $self, $key ) = @_;
    return cookie( $key );
}

sub set_cookie_value_for_key {
    my ( $self, $value, $key ) = @_;
    cookie $key => $value;
}

1;