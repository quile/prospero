package Prospero::Adaptor::Plack;

use strict;
use warnings;

use Plack;

use Prospero::Request::Plack;

sub handle_incoming_request {
    my ( $class, $env ) = @_;

    # roughly it goes like this
    my $request = Prospero::Request::Plack->new( Plack::Request->new( $env ) );
    my $response;

    my $context = Prospero::Context->new(
        incoming_request_frame => Prospero::RequestFrame->new(),
    );

    # figure out where to route request
    my $component = $context->endpoint_for( $request ) or die "Can't route request";

    $component->take_values_from_request( $request, $context );
    my $result = $component->action_result_for_request( $request, $context );

    # decide what to do with result of action
    if ( $result ) {
        if ( ref( $result ) && $result->isa( "Prospero::Component" ) ) {

        }
    }
    #     if ($actionResult) {
    #         if (UNIVERSAL::isa($actionResult, "IF::Component")) {
    #             IF::Log::debug("Action returned a component $actionResult");
    #             $component = $actionResult;
    #             my $componentName = $component->componentNameRelativeToSiteClassifier();
    #             my $templateName = IF::Component::__templateNameFromComponentName($componentName);
    #             $response = IF::Response->new();
    #             my $template = $context->siteClassifier()->bestTemplateForPathAndContext($templateName, $context);
    #             $response->setTemplate($template);
    #         } elsif (UNIVERSAL::isa($actionResult, "IF::Response")) {
    #             # action returned a response; we have to assume it's fully populated and return it
    #             $response = $actionResult;
    #         } else {
    #             return $className->redirectBrowserToAddressInContext($actionResult, $context);
    #         }
    #     } else {
    #         $response = $className->responseForComponentInContext($component, $context);
    #     }
}

# sub handler {
#     my ($className, $applicationName, $env) = @_;
#     my $context;
#     my ($ERROR_CODE, $ERROR_MSG);
#
#     # rewrite incoming URLs and munge the query string.
#     $className->transHandler($applicationName, $env);
#
#     my $req = IF::Request::Plack->new(Plack::Request->new($env));
#     $req->setApplicationName($applicationName);
#
#     my $res;
#
#     IF::Log::setLogMask(0xffff);
#     IF::Log::debug("=====================> Main handler invoked");
#
#     # generate a context for this request
#     $context = $className->contextForRequest($req);
#     unless ($context) {
#         $ERROR_MSG = "Malformed URL: Failed to instantiate a context for request ".$req->uri();
#         #$ERROR_CODE = NOT_FOUND;
#         return;
#     }
#
#     # figure out what app and instance this is
#     my $application = $context->application();
#     unless ($application) {
#         $ERROR_MSG = "No application object found for request ".$req->uri();
#         #$ERROR_CODE = NOT_FOUND;
#         return;
#     }
#
#     # Initialise the logging subsystem for this transaction
#     $className->startLoggingTransactionInContext($context);
#
#     # Set the language for this transaction so the I18N methods
#     # use the right strings.
#     IF::I18N::setLanguage($context->language());
#
#     # figure out which component we're going to be running with
#     my $component = $className->targetComponentForContext($context);
#     unless ($component) {
#         $ERROR_MSG = "No component object found for request ".$req->uri();
#         #$ERROR_CODE = NOT_FOUND;
#         return;
#     }
#     IF::Log::error("$$ - ".$context->urlWithQueryString());
#
#     my $response;
#
#     # just before append to response begins, push the CURRENT request's
#     # sid into the query dictionary in case any component (like AsynchronousComponent)
#     # decides to fish around in there to build urls
#     $context->queryDictionary()->{$context->application()->sessionIdKey()} = $context->session()->externalId();
#
#     $className->allowComponentToTakeValuesFromRequest($component, $context);
#
#     my $actionResult = $className->actionResultFromComponentInContext($component, $context);
#
#     # if we have a result from the action, set the component and the response
#     # to be the appropriate objects
#     if ($actionResult) {
#         if (UNIVERSAL::isa($actionResult, "IF::Component")) {
#             IF::Log::debug("Action returned a component $actionResult");
#             $component = $actionResult;
#             my $componentName = $component->componentNameRelativeToSiteClassifier();
#             my $templateName = IF::Component::__templateNameFromComponentName($componentName);
#             $response = IF::Response->new();
#             my $template = $context->siteClassifier()->bestTemplateForPathAndContext($templateName, $context);
#             $response->setTemplate($template);
#         } elsif (UNIVERSAL::isa($actionResult, "IF::Response")) {
#             # action returned a response; we have to assume it's fully populated and return it
#             $response = $actionResult;
#         } else {
#             return $className->redirectBrowserToAddressInContext($actionResult, $context);
#         }
#     } else {
#         $response = $className->responseForComponentInContext($component, $context);
#     }
#
#     # now we have $component and $response, no matter what the results of
#     # the action were.
#     if ($actionResult != $response) {
#         my $responseResult = $className->allowComponentToAppendToResponseInContext($component, $response, $context);
#         if ($responseResult) {
#             return $className->redirectBrowserToAddressInContext($responseResult, $context);
#         }
#     }
#
#     # This sends the generated response back to the client:
#     # $className->returnResponseInContext($response, $context);
#
#     $res = $className->plackResponseFromResponse($response, $context);
#
#     IF::Log::endLoggingTransaction();
#
#     $res->finalize();
# }

1;