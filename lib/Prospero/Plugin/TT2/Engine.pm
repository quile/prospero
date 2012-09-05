package Prospero::Plugin::TT2::Engine;

use base qw(Template);
use Prospero::Plugin::TT2::Grammar;

sub new {
    my ( $class, $config ) = @_;
    $config->{GRAMMAR} ||= Prospero::Plugin::TT2::Grammar->new();
    return $class->SUPER::new( $config );
}

1;