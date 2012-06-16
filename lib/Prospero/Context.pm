package Prospero::Context;

use strict;
use warnings;

use base qw( Prospero::Object );

sub environment      { return $_[0]->{_environment}   }
sub set_environment  { $_[0]->{_environment} = $_[1]  }
sub render_state     { return $_[0]->{_render_state}  }
sub set_render_state { $_[0]->{_render_state} = $_[1] }

1;