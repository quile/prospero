package Prospero::Plugin;

use strict;
use warnings;

my $_plugins = [];

# TODO:kd - probably pass in come optional config here
sub register_plugin {
    my ( $class, @opts ) = @_;

    my $options = { @opts };

    my $callbacks = $options->{callbacks} || {};
    my $config    = $options->{config}    || {};
    print STDERR "... registering Prospero plugin $class ... \n";
    push @$_plugins, { callbacks => $callbacks, config => $config };
}

sub execute_callback_with_arguments {
    my ( $class, $callback, @arguments ) = @_;
    foreach my $plugin (@{ $_plugins }) {
        my $callback = $plugin->{ callbacks }->{ $callback };
        next unless $callback;
        $callback->( @arguments );
    }
}

1;