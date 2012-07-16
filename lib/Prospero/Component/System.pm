package Prospero::Component::System;

use strict;
use base qw(
    Prospero::Plugin::TT2::Component
);

sub template_path {
    my ( $self ) = @_;
    my $name = ref( $self );
    $name =~ s!.*::!!g;
    return "$name.tt2";
}

1;