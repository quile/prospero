package Unit::Component::Hello;

use strict;
use warnings;
use base qw( Prospero::Component::TT2 );

use Prospero::BindingDictionary;
use Prospero::PageResource;

use Unit::Component::Foo;
use Unit::Component::Bar;

sub required_page_resources {
    return [
        Prospero::PageResource->javascript( "/foo/bar/bananas.js" ),
        Prospero::PageResource->stylesheet( "/foo/baz/mangos.css" ),
    ];
}

sub foo { "bar" }
sub bar { "baz" }

sub mango     { return $_[0]->{mango}  }
sub set_mango { $_[0]->{mango} = $_[1] }

sub bindings {
    return Prospero::BindingDictionary->new({
        foo => {
            type => "Unit::Component::Foo",
            goo => sub { "This is goo from above" },
            banana => q(mango),
        },
        bar => {
            type => "Unit::Component::Bar",
        },
    })
}

1;