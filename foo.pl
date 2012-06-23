#!/usr/bin/env perl

use lib 'lib';
use lib 't/lib';

use strict;
use Data::Dumper;

use Prospero;

use Prospero::Component::TT2;
use Prospero::Component::TT2::Grammar;
use Prospero::Context;

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
});

my $component = Unit::Component::Hello->new();

my $output = $component->render_in_context( $context );

print $output;

print Dumper $component;
