package Functional::App;

use Prospero;
use Prospero::Adaptor::Dancer;
use Unit::Component::FormTest;

use Dancer ':syntax';

use Dancer::Plugin::Prospero;

our $VERSION = '0.1';


get '/foo/bar' => sub {
    my $page = prospero_page( "Unit::Component::FormTest" );

    prospero_handler $page;
};

get '/foo/bar/submit' => sub {
    my $page = prospero_page( "Unit::Component::FormTest" );

    prospero_handler $page => "submit";
};

true;
