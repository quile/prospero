package Unit::Component::Hello;

use strict;
use warnings;
use base qw( Prospero::Plugin::TT2::Component );

use Prospero::BindingDictionary;
use Prospero::PageResource;
use Prospero::Component::System::TextField;

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
sub gronk     { return $_[0]->{_gronk}  }
sub set_gronk { $_[0]->{_gronk} = $_[1] }

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
        text_field => {
            type => "Prospero::Component::System::TextField",
            value => q(gronk),
        },
    })
}

1;