package Prospero::Plugin::Javascript;

use strict;
use warnings;

use Data::Dumper;

use base qw( Prospero::Plugin );

__PACKAGE__->register_plugin(
    callbacks => {
        component_will_render => sub {
            my ( $component, $response, $context ) = @_;
            # build the tree of components here
            #print STDERR "   ==> Component $component is about to render\n";
        },
        component_did_render => sub {
            my ( $component, $response, $context ) = @_;
            # insert the JS that builds the client-side page structure
            #print STDERR "   ==> Component $component finished rendering\n";
            my $javascript_class = $component->value_for_key("javascript_class") || "prospero.Component";
            push @{ $context->transaction_value_for_key( "javascript_components" ) }, {
                class => $javascript_class,
                node_id => $component->node_id(),
            };
        },
        page_will_render => sub {
            my ( $page, $response, $context ) = @_;
            #print STDERR "==> Page $page is about to render\n";
            $context->set_transaction_value_for_key( [], "javascript_components" );
        },
        page_did_render => sub {
            my ( $page, $response, $context ) = @_;
            print STDERR "==> Page $page finished rendering\n";
            #print Dumper $context->transaction_value_for_key( "javascript_components" );
            my $js = "";
            foreach my $c (@{ $context->transaction_value_for_key( "javascript_components" ) }) {
                $js .= "new $c->{class}('$c->{node_id}');\n";
            }
            $js = sprintf("<script \"type=text/javascript\">\n%s\n</script>", $js);

            my $content = $response->content();
            if ( $content =~ m!</body>!i ) {
                $content =~ s!</body>!$js\n</body>!;
            } else {
                $content .= $js;
            }
            $response->set_content( $content );
        },
    },
);

1;