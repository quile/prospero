package Unit::Component::Hello;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::BindingDictionary;

sub foo { "bar" }
sub bar { "baz" }

sub bindings {
    return Prospero::BindingDictionary->new({
        foo => {
            type => "Unit::Component::Foo",
        },
        bar => {
            type => "Unit::Component::Bar",
        },
    })
}

1;