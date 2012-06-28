# This is kind of a stop-gap class to just
# make it easier to develop the rest of the
# system without needing to hook it up to a
# real request-response loop.

package Prospero::Request::Offline;

use strict;
use warnings;

use base qw( Prospero::Request );

use Prospero::Utility qw( array_from_object );

sub new {
    my ( $class, @args ) = @_;
    my $arguments = { @args };
    return bless {
        'headers_in'  => $arguments->{headers_in} || {},
        'headers_out' => $arguments->{headers_out} || {},
        'param'       => $arguments->{param}
                      || $arguments->{params}
                      || {},
    }, $class;
}

sub uri {
    my $self = shift;
    return $self->{_uri} if $self->{_uri};
    return "nowayjose";
}

sub setUri {
    my ( $self, $value ) = @_;
    $self->{_uri} = $value;
}

sub headers_in {
    my ( $self ) = @_;
    return $self->{headers_in};
}

sub headers_out {
    my ( $self ) = @_;
    return $self->{headers_out};
}

sub param {
    my ( $self, $key, $value ) = @_;
    if ( $key ) {
        if ( $value ) {
            $value = array_from_object( $value );
            push @{$self->{param}->{$key} ||= []}, @$value;
        } else {
            my $v = $self->{param}->{$key};
            if ( wantarray() ) {
                return @$v if ref( $v ) eq "ARRAY";
                return $v;
            } else {
                return $v->[0] if ref( $v ) eq "ARRAY";
                return $v;
            }
        }
    } else {
        return keys %{$self->{param}} if wantarray();
    }
    return;
}

sub dropCookie {
    return undef;
}

1;
