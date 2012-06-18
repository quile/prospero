package Prospero::RenderState;

use strict;
use warnings;

use base qw( Prospero::Object );

sub new {
    my $className = shift;
    my $self = {
        _page_context => [1],
        _loop_context => [],
        _rendered_components => {},
    };
    return bless $self, $className;
}

# These are used in page generation
sub increase_page_context_depth {
    my $self = shift;
    push (@{$self->{_page_context}}, 0);
}

sub decrease_page_context_depth {
    my $self = shift;
    pop (@{$self->{_page_context}});
}

sub increment_page_context_number {
    my $self = shift;
    $self->{_page_context}->[-1] += 1;
}

sub page_context_number {
    my $self = shift;
    return join("_", @{$self->{_page_context}});
}

# these mirror the page context stuff but are used
# with a page context for keeping track of loops:
sub increase_loop_context_depth {
    my ($self) = @_;
    push (@{$self->{_loop_context}}, 0);
}

sub decrease_loop_context_depth {
    my ($self) = @_;
    pop (@{$self->{_loop_context}});
}

sub increment_loop_context_number {
    my ($self) = @_;
    $self->{_loop_context}->[ -1 ] += 1;
}

sub loop_context_number {
    my ($self) = @_;
    return join("_", @{$self->{_loop_context}});
}

sub loop_context_depth {
    my ($self) = @_;
    return scalar @{$self->{_loop_context}};
}

1;