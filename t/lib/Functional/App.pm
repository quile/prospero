package Functional::App;

use Prospero;
use Prospero::Adaptor::Dancer;
use Unit::Component::FormTest;

use Dancer ':syntax';

our $VERSION = '0.1';


get '/foo/bar' => sub {
    my $context = Prospero::Adaptor::Dancer->context_from_request( request );

    # my $context = Prospero::Context->new({
    #     environment => {
    #         TT2_CONFIG => {
    #             INCLUDE_PATH => [ "../../../share/templates/en", "../../templates", ],
    #             DEBUG => 1,
    #         },
    #     },
    #     outgoing_request_frame => Prospero::RequestFrame->new(),
    # });

    my $component = Unit::Component::FormTest->new();
    return $component->render_in_context( $context );
};

true;
