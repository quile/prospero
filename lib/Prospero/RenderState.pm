package Prospero::RenderState;

use strict;
use warnings;

use base qw( Prospero::Object );

use Prospero::Utility qw( array_from_object );

sub new {
    my $class = shift;
    my $self = $class->_blank_state();
    return bless $self, $class;
}

sub _blank_state {
    return {
        _page_context => [ 0 ],
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

    $self->increment_node_id();
    return $self->node_id();
}


# ----------- these help components manage page resources ---------

sub page_resources {
    my ( $self ) = @_;
    return $self->_ordered_page_resources();
}

# this holds the resources in the order they are added.  It's not
# particularly accurate because components get included/rendered
# in an order that's not the same as the order they appear on
# the page, BUT it means that all the resources a given component
# requests WILL BE in the order that it requests them.

sub _ordered_page_resources {
    my ($self) = @_;
    return $self->{_ordered_page_resources} || [];
}

sub add_page_resource {
    my ( $self, $resource ) = @_;
    $self->{_page_resources} ||= {};
    $self->{_ordered_page_resources} ||= [];
    # Only add it to the list if it's not already there.
    my $location = $resource->location();
    unless ($self->{_page_resources}->{$location}) {
        push ( @{ $self->{_ordered_page_resources} }, $resource );
    }
    $self->{_page_resources}->{$location} = $resource;
}

sub add_page_resources {
    my ( $self, $resources ) = @_;
    $resources = array_from_object( $resources );
    foreach my $r ( @$resources ) {
        $self->add_page_resource( $r );
    }
}

sub remove_page_resource {
    my ( $self, $resource ) = @_;
    $self->{_page_resources} ||= {};
    delete $self->{_page_resources}->{$resource->location()};
    $self->{_ordered_page_resources} = [ grep { $_->location() ne $resource->location() } @{ $self->{_ordered_page_resources} } ];
}

1;