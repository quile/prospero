package Functional::App;

use Prospero;
use Prospero::Adaptor::Dancer;
use Unit::Component::FormTest;

use Dancer ':syntax';

use Dancer::Plugin::Prospero;

our $VERSION = '0.1';


get '/foo/bar' => sub {
    my $component = Unit::Component::FormTest->new();

    $component->rewind_request_in_context( prospero_request, prospero_context );
    return $component->render_in_context( prospero_context );
};

true;
