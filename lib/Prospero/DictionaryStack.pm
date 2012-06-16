package Prospero::DictionaryStack;

use strict;
use warnings;

use base qw( Prospero::Object );

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->reset_frames();
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
    my ( $self ) = @_;
    $self->{_frames} = [ {} ];
}

1;