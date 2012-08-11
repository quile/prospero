package Prospero;

use 5.008;
use strict;
use warnings;

use Prospero::Object;
use Prospero::DictionaryStack;
use Prospero::BindingDictionary;
use Prospero::Binding;
use Prospero::Context;
use Prospero::Request;
use Prospero::Response;
use Prospero::RenderState;
use Prospero::Component;
use Prospero::RequestFrame;
use Prospero::Utility;
use Prospero::Components;

=head1 NAME

Prospero - Solve the hard problems, not the easy ones.

=head1 VERSION

Version 0.1

=cut

our $VERSION = '0.1';


=head1 SYNOPSIS

Prospero is a platform-independent system for

=over 4

=item * Building pages out of reusable components

=item * Handling complex dynamic forms transparently

=item * Structuring your display logic entirely separately
from everything else, allowing very easy "skin" changes, i18n, etc.

=back

It is designed on solid engineering principles and has as its direct spiritual
ancestor Apple's B<WebObjects> framework.  It uses techniques found in
the B<Cocoa> framework (previously B<NeXTStep>) to provide functionality
that will be familiar to programmers of B<OSX>, B<iOS> and B<WebObjects>.

It is not bound to any "popular" web framework and has no dependencies
on any of them, insofar as it is designed to be platform-neutral.  It can
function equally well within a web framework, as its own, or entirely off-line.

=head1 AUTHOR

Kyle Dawkins, C<< <info at kyledawkins.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-prospero at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Prospero>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Prospero

=head1 ACKNOWLEDGEMENTS

This code is a ground-up clean-room re-implementation of some parts of
the "IF" framework found here:

L<https://github.com/quile/if-framework>

but does not directly use any of the "IF" code.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Kyle Dawkins.

This program is released under the following license: MIT


=cut

1; # End of Prospero
