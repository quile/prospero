#!/usr/bin/env perl

use lib 'lib';
use lib 't/lib';

use strict;
use Data::Dumper;

use Prospero;

use Prospero::Component::TT2;
use Prospero::Component::TT2::Grammar;

use Unit::Component::Hello;
use Unit::Component::Foo;
use Unit::Component::Bar;
use Unit::Component::Baz;

my $context = Prospero::Context->new({
    environment => {
        TT2_CONFIG => {
            INCLUDE_PATH => "t/templates",
            GRAMMAR => Prospero::Component::TT2::Grammar->new(),
            DEBUG => "parser",
        },
    },
    outgoing_request_frame => Prospero::RequestFrame->new(),
});

my $component = Unit::Component::Hello->new();

my $output = $component->render_in_context( $context );

print $output;

print Dumper( $context->outgoing_request_frame() );

$context->set_incoming_request_frame( $context->outgoing_request_frame() );
$context->set_outgoing_request_frame();

#delete $context->incoming_request_frame()->rendered_components()->{"Unit::Component::Baz"}->{"2_3_9"};

my $request = Prospero::Request->new();
$component->rewind_request_in_context( $request, $context );
