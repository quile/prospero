package Prospero::Manual::Overview;

1;

=pod

=head1 NAME

Prospero::Manual::Overview - Prospero's Architecture

=head1 OVERVIEW

Prospero is designed to be independent of any specific
web framework.  The reason for this is simple: it should
benefit everyone, rather than tying itself to a single platform.
There is no compelling reason to force it to be coupled with
a specific framework, and there are numerous benefits to making
it standalone:

=over

=item Few dependencies

Prospero has very few dependencies on its own.  Dependencies
are nasty, and we all know how bad it can be in dependency hell.

=item Clarity

By avoiding any specific implementation, Prospero itself becomes
clearer and better defined; there are no blurry lines between
Prospero and framework X.

=item Decoupling

If it's not tied to any web framework, then it's not technically even
coupled to the web at all; it could have numerous uses - smart
serialisation/deserialisation for example.

=back

=head1 ARCHITECTURE

Prospero is spiritually a descendant of Apple's WebObjects framework
in a few specific ways:

=over

=item 1. Component-based page-building

Pages are assembled using reusable components.  These components
can enclose other components, and are entirely reusable insofar
as not only their templates but also their behaviours are portable
across applications.  This is possible because of...

=item 2. Intelligent response handling

If you build a form using Prospero, when your form is submitted,
Prospero can "rewind" the incoming request containing the form information
and apply it to the components that generated it, allowing them to
handle the incoming values and push them into your object graph.
This reusability is made possible through the use of...

=item 3. Bindings

Bindings are the gearing that makes it possible to connect your objects
and data to the input and output.  Each component has multiple bindings
that connect it to important points in its template - perhaps you might
"bind" an object's "name" property to a text field in your form, for
example.   When that form is submitted, Prospero unwinds the incoming
request and takes the value of that text field and pushes it into
the object's "name" property, because it's been "bound" to it.
Bindings are made possible because of...

=item 4. Key-value coding

Key-value coding is a concept that is common in Apple's (formerly NeXT's)
frameworks (Cocoa, WebObjects, EOF, etc) and it's a very powerful concept
that is sadly under-used outside of the Apple world.  The simple
gist is that it allows you to represent points in your object graph
using dotted key-paths that are independent of the underlying implementation.

For example, let's say you have an object $person that has a name property.
You could refer to that using

  $person->value_for_key("name")

and it will return the name.  You might wonder why this is better than just
saying

  $person->name()

and the answer comes clear when you traverse relationships.  Let's say your
$person object has a related object of the same type called "boss".  So
in normal perl you'd say

  $person->boss()

to get that object, and

  $person->boss()->name()

to get the boss's name.  But if you said

  $person->value_for_key( "boss.name" )

you'd also get the boss's name, independently of the implementation.  Still,
you might wonder about the benefits.  But the real benefit is that perhaps you
want to B<set> the value of that property.   If it's specified with a key-path,
you can simply do

  $person->set_value_for_key( "Murray Hewitt", "boss.name" );

And now, you might wonder why this is better than

  $person->boss()->set_name( "Murray Hewitt" )

and the answer lies in the need to allow data flow into and out of the properties
you want bound into your web components.   Using key-value coding, you can specify
a key path, for example, in a binding:

    value => 'boss.name',

and when the incoming request is "rewound", the system knows to
set the value of boss.name to the incoming value.  If you still need convincing
you should read up more about L<Object::KeyValueCoding>.

=back

=head1 COMPONENTS

Prospero encourages you to build your pages out of components, and makes those
components reusable.  You probably already build your pages out of templates
and snippets and other templates, so you are probably already part of the way
there.   However, chances are that you haven't really realised the full potential
of building your pages up out of smaller, reusable units, because your framework
hasn't made it possible.  Now, for example, it's possible to build complicated
form components that you can share with the world, and you can reap the benefits
of components built by others.

=head1 RESPONSE-HANDLING

The key idea in Prospero is that of response "rewinding".  This is not new
to Prospero - it is done by Apple's WebObjects, or the Tapestry framework.
Essentially on a relevant incoming request, the previous page is
re-rendered and "bound" values are synchronised based on their binding
specifications.  The most important item that makes this possible is the
L<Prospero::RequestFrame>.

=head2 Request::Frame

When a page is rendered, the render tree is stored in the outgoing
request frame.  It doesn't contain any content - the content is irrelevant.
Instead, it records the nodes and node-types of the render tree.  Each node
has a unique ID, so when the incoming request is "rewound", the nodes can
be matched exactly to the incoming data.

=head2 Binding Synchronising

As an incoming request frame is rewound, each component in the request
frame's render tree has the chance to take values from the incoming request,
after which its bindings are synchronised back up the render tree.
This makes sense, because when the page was originally rendered, nodes
higher in the tree push their values into components beneath them in the tree.
What it means for you is that you can push your objects into your page,
and render it, and when the user responds, all the data is sent to the right
place without you ever having to do anything.



=head1 AUTHOR

Kyle Dawkins, info@kyledawkins.com

=head1 COPYRIGHT

This module is copyright (c) 2012 Kyle Dawkins <info@kyledawkins.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
