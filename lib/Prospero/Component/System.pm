package Prospero::Component::System;

use strict;
use base qw(
    Prospero::Plugin::TT2::Component
);

use Prospero::PageResource;

sub required_page_resources {
    my ($self) = @_;
    return [
        Prospero::PageResource->javascript("http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"),
        Prospero::PageResource->javascript("/javascript/prospero.js"),
    ];
}


sub template_path {
    my ( $self ) = @_;
    my $name = ref( $self );
    $name =~ s!.*::!!g;
    return "$name.tt2";
}

1;