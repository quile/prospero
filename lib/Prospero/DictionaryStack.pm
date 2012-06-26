package Prospero::DictionaryStack;

use strict;
use warnings;

use base qw( Prospero::Object );

sub new {
    my ( $class, $initial_frame ) = @_;
    my $self = $class->SUPER::new();

    $self->reset_frames( $initial_frame );
    return $self;
}

sub push_frame {
    my ( $self, $dictionary ) = @_;
    $dictionary ||= {};
    unshift @{ $self->{_frames} }, $dictionary;
}

sub pop_frame {
    my ( $self ) = @_;

    return undef unless scalar @{ $self->{_frames} } > 1;
    return shift @{ $self->{_frames} };
}

sub value_for_key {
    my ( $self, $key ) = @_;

    foreach my $frame (@{ $self->{_frames} }) {
        return $frame->{$key} if exists $frame->{ $key };
    }
    return undef;
}

sub set_value_for_key {
    my ( $self, $value, $key ) = @_;
    $self->{_frames}->[0]->{ $key } = $value;
}

sub reset_frames {
    my ( $self, $initial_frame ) = @_;
    $initial_frame ||= {};
    $self->{_frames} = [ $initial_frame ];
}

sub keys {
    my ( $self ) = @_;

    my $keys = [];
    foreach my $frame (@{ $self->{_frames} }) {
        push ( @$keys, keys %$frame );
    }
    my $uniq = {};
    map { $uniq->{$_}++ } @$keys;
    return [ keys %$uniq ];
}

1;