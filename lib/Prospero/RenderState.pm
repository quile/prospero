package Prospero::RenderState;

use strict;
use warnings;

use base qw( Prospero::Object );

sub new {
    my $class = shift;
    my $self = $class->_blank_state();
    return bless $self, $class;
}

sub _blank_state {
    return {
        _page_context => [ 1 ],
    }
}

sub reset {
    my ( $self ) = @_;
    my $state = $self->_blank_state();
    foreach my $key ( keys %{ $state } ) {
        $self->{$key} = $state->{$key};
    }
}

# These are used in page generation
sub increase_page_context_depth {
    my $self = shift;
    push (@{$self->{_page_context}}, 0);
    return $self;
}

sub decrease_page_context_depth {
    my $self = shift;
    pop (@{$self->{_page_context}});
    return $self;
}

sub increment_node_id {
    my $self = shift;
    $self->{_page_context}->[-1] += 1;
    return $self;
}

sub node_id {
    my $self = shift;
    return join("_", @{$self->{_page_context}});
}

sub next_node_id {
    my ( $self ) = @_;

    my $next = $self->node_id();
    $self->increment_node_id();
    return $next;
}

1;