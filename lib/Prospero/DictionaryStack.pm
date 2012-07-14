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

sub has_value_for_key {
    my ( $self, $key ) = @_;
    foreach my $frame (@{ $self->{_frames} }) {
        return 1 if exists $frame->{ $key };
    }
    return 0;
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

sub as_flat {
    my ( $self ) = @_;
    my $keys = $self->keys();
    my $hash = {};
    foreach my $key ( @$keys ) {
        $hash->{$key} = $self->value_for_key( $key );
    }
    return Prospero::DictionaryStack->new( $hash );
}

sub frames {
    my ( $self ) = @_;
    return $self->{_frames};
}

# TODO:kd - this needs to live somewhere else
sub init_with_query_string {
    my ( $self, $query_string ) = @_;

    my @kvPairs = split(/\&/, $query_string);
    foreach my $kvPair (@kvPairs) {
        my ( $key, $value ) = $kvPair =~ /^(.*)=(.*)$/;
        next unless ( $key && $value );
        $key = URI::Escape::uri_unescape($key);
        $value = URI::Escape::uri_unescape($value);
        my $current_value = $self->value_for_key($key);
        if ( $current_value ) {
            $current_value = array_from_object( $current_value );
            push @$current_value, $value;
        } else {
            $current_value = $value;
        }
        $self->set_value_for_key( $current_value, $key );
    }
    return $self;
}

1;