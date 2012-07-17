package Unit::Component::FormTest;

use strict;
use warnings;
use base qw( Prospero::Plugin::TT2::Component);

use Prospero::BindingDictionary;
use Prospero::PageResource;

use Prospero::Component::System::Components;

sub stuff     { return $_[0]->{_stuff}  }
sub set_stuff { $_[0]->{_stuff} = $_[1] }

sub bindings {
    return Prospero::BindingDictionary->new({
        form => {
            type => "Prospero::Component::System::Form",
            action => sub { '/foo/bar/baz' },
        },
        hidden_field => {
            type => "Prospero::Component::System::HiddenField",
            value => q(stuff.hidden_field),
        },
        text_field => {
            type => "Prospero::Component::System::TextField",
            value => q(stuff.text_field),
        },
        password => {
            type => "Prospero::Component::System::Password",
            value => q(stuff.text_field),
        },
        text => {
            type => "Prospero::Component::System::Text",
            value => q(stuff.text),
        },
        submit_button => {
            type => "Prospero::Component::System::SubmitButton",
            value => sub { 'Click me!' },
        },
    });
}

1;