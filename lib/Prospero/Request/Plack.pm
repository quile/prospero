package Prospero::Request::Plack;

use base qw( Prospero::Request );

sub new {
    my ( $class, $request ) = @_;
    return bless {
        '_request'  => $request,
    }, $class;
}

sub plack_request {
    my ( $self ) = @_;
    return $self->{_request};
}

# This is probably not correct, and should be
# $self->{_request}->uri() instead... TBD.
sub uri {
    my $self = shift;
    return $self->{_request}->path_info();
}

sub header_for_key {
    my ( $self, $key ) = @_;
    my $headers = $self->{_request}->headers();
    return undef unless $headers;
    return $headers->header( $key );
}

sub param {
    my ( $self, $key, $value ) = @_;
    if ( $key ) {
        if ( $value ) {
            $self->unimplemented();
        } else {
            if ( wantarray() ) {
                my @param = $self->{_request}->param( $key );
                return @param;
            } else {
                my $param = $self->{_request}->param( $key );
                return $param;
            }
        }
    } else {
        my @params = $$self->{_request}->param();
        return @params;
    }
    return;
}

sub cookie_value_for_key {
    my ( $self, $key ) = @_;
    return $self->{_request}->cookie->{$key};
}

1;