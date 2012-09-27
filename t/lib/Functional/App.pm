package Functional::App;

use Prospero;

use Dancer ':syntax';

use Dancer::Plugin::Prospero;

use Prospero::Plugin::Javascript;

our $VERSION = '0.1';

get '/foo/bar' => sub {
    my $page = prospero_page( "Unit::Component::FormTest" );

    prospero_handler $page;
};

get '/foo/bar/submit' => sub {
    my $page = prospero_page( "Unit::Component::FormTest" );

    prospero_handler $page => "submit";
};

get '/javascript/prospero.js' => sub {
    send_file( "../../../share/javascript/prospero.js", system_path => 1 );
};

true;
