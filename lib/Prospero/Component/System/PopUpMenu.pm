package Prospero::Component::System::PopUpMenu;

use strict;
use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

use Prospero::PageResource;
use Text::Unaccent::PurePerl;

sub required_page_resources {
    my ( $self ) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/PopUpMenu.js"),
    ];
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    # Don't need to call super as there are no subcomponents.
    # Subclasses of this don't need to call super either.

    $self->set_selection( $request->form_value_for_key( $self->name() ) );

    # if ( $self->allows_other() ) {
    #     if ( $self->selection() eq $self->other_value() ) {
    #         if ($self->other_alternate_key()) {
    #             $self->set_value_for_key( $self->other_text(), "parent." . $self->other_alternate_key());
    #         } else {
    #             $self->set_selection( $self->other_text() );
    #         }
    #     }
    # }
    $self->reset_values();
}

sub reset_values {
    my ( $self ) = @_;

    $self->set_any_string('');
    $self->set_any_value('');
    delete $self->{_list};
    delete $self->{_name};
}

# sub list {
#     my $self = shift;
#     my $list;
#     if ($self->valueForKey("LIST_TYPE") eq "RAW") {
#         $list = $self->rawList();
#     } else {
#         $list = $self->{LIST} || [];
#     }
#     if ($self->allowsNoSelection()) {
#         #unshift (@$list, {});
#         if ($self->valueForKey("VALUE") && $self->valueForKey("DISPLAY_STRING")) {
#             unshift (@$list, {
#                 $self->valueForKey("VALUE") => $self->anyValue(),
#                 $self->valueForKey("DISPLAY_STRING") => $self->anyString() }
#             );
#         } else {
#             unshift (@$list, {});
#         }
#     }
#     return $list;
# }
#
# sub setList {
#     my $self = shift;
#     $self->{LIST} = shift;
# }

sub display_string_for_item {
    my ( $self, $item ) = @_;

    if ( UNIVERSAL::can($item, "value_for_key") ) {
        return $item->value_for_key( $self->value_for_key( "display_string" ) );
    }
    my $key = $self->value_for_key( "display_string" );

    if ( ref($item) eq "HASH" ) {
        if ( exists( $item->{$key} ) ) {
            return $item->{$key};
        } else {
            return undef;
        }
    }
    return $item;
}

sub value_for_item {
    my ( $self, $item ) = @_;

    if ( UNIVERSAL::can( $item, "value_for_key" ) ) {
        return $item->value_for_key( $self->value_for_key( "value" ) );
    }
    if ( ref($item) eq "HASH" ) {
        my $key = $self->value_for_key( "value" );
        if (exists($item->{$key})) {
            return $item->{$key};
        } else {
            return undef;
        }
    }
    return $item;
}

# sub rawList {
#     my $self = shift;
#     my $blessedList = [];
#     foreach my $i (@{$self->valueForKey("LIST")  || []}) {
#         push @$blessedList, bless($i, 'IF::Interface::KeyValueCoding');
#     }
#     return $blessedList;
# }

sub item_is_selected {
    my ( $self, $item ) = @_;
    my $value;

    if ( UNIVERSAL::can( $item, "value_for_key" ) ) {
        $value = $item->value_for_key( $self->value_for_key( "value" ) );
    } elsif ( ref( $item ) eq "HASH" && exists $item->{$self->value_for_key( "value" )} ) {
        $value = $item->{$self->value_for_key( "value" )};
    } else {
        $value = $item;
    }

    return 0 if $value eq "";

    my $values = $self->value_for_key( "selected_values" ) || [ $self->selection() ];
    return 0 unless ( ref( $values ) );
    #TODO: Optimise this by hashing it
    foreach my $selected_value ( @$values ) {
        unless ( ref $selected_value ) {
            return 1 if $self->values_are_equal( $selected_value, $value );

            # this could be optimised:
            if ($selected_value =~ /^[0-9\.]+$/ &&
                $value =~ /^[0-9\.]+$/ &&
                $selected_value == $value ) {
                return 1;
            }
            next;
        }
        if ( UNIVERSAL::can( $selected_value, "value_for_key" ) ) {
            return 1 if $self->values_are_equal( $selected_value->value_for_key( $self->value_for_key( "value" ) ), $value );
        } else {
            return 1 if $self->values_are_equal( $selected_value->{$self->value_for_key( "value" )}, $value );
        }
    }
    return 0;
}

sub values_are_equal {
    my ( $self, $a, $b ) = @_;

    if ( $self->should_ignore_accents() ) {
        $a = unac_string( "UTF-8", $a );
        $b = unac_string( "UTF-8", $b );
    }

    if ( $self->should_ignore_case() ) {
        $a = lc( $a );
        $b = lc( $b );
    }

    return ($a eq $b);
}

# sub set_values {
#     my ( $self, $values ) = @_;
#     $self->{_values} = $values;
#
#     if ( $self->{_labels} ) {
#         $self->{_list} = $self->list_from_labels_and_values();
#     }
# }
#
# sub set_labels {
#     my ( $self, $values ) = @_;
#     $self->{_labels} = $values;
#
#     if ( $self->{_values} ) {
#         $self->{_list} = $self->list_from_labels_and_values();
#     }
# }
#
# sub list_from_labels_and_values {
#     my ( $self ) = @_;
#
#     return [] unless $self->{_values} && $self->{_labels};
#
#     my $list = [];
#     foreach my $value ( @{ $self->{_values} } ) {
#         push (@$list, { VALUE => $value, LABEL => $self->{_labels}->{$value} } );
#     }
#     return $list;
# }

sub name     { return $_[0]->{_name} || $_[0]->node_id() }
sub set_name { $_[0]->{_name} = $_[1] }

sub list {
    my ( $self ) = @_;

   # $DB::single = 1;

    return $self->{_list} if $self->{_list};

    my $list;
    if ($self->values() &&
        $self->value() &&
        $self->display_string()) {
        $list = [];
        foreach my $value (@{$self->values()}) {
            push (@$list, { $self->value() => $value, $self->display_string() => $self->labels()->{$value} });
        }
    } else {
        $list = [];
        foreach my $item (@{$self->{list}}) {
            push (@$list, $item);
        }
    }

    if ($self->allows_no_selection()) {
        if ($self->value() && $self->display_string()) {
            unshift (@$list, { $self->value() => $self->any_value(), $self->display_string() => $self->any_string() });
        } else {
            unshift (@$list, ''); # TODO this is bogus but the only way to ensure that an empty value gets sent in this case
        }
    }

    # if ($self->allows_other()) {
    #     # Check to see if other is already in the list...
    #     my $has_other = 0;
    #     foreach my $item (@$list) {
    #         if (ref($item)) {
    #             if ($item->{$self->value()} eq $self->other_value()) {
    #                 $has_other = 1;
    #                 last;
    #             }
    #         } else {
    #             if ($item eq $self->other_value()) {
    #                 $has_other = 1;
    #                 last;
    #             }
    #         }
    #     }
    #     # ...Only add the other value if it doesn't exist.
    #     unless ($has_other) {
    #         if ($self->value() && $self->display_string()) {
    #             push (@$list, {$self->value() => $self->other_value(), $self->display_string() => $self->other_label()});
    #         } else {
    #             push (@$list, $self->other_value());
    #         }
    #     }
    # }
    $self->{_list} = $list;
    return $self->{_list};
}

sub set_list {
    my ( $self, $list ) = @_;
    $self->{_list} = $list;
}

sub value     { return $_[0]->{_value} || "VALUE" }
sub set_value { $_[0]->{_value} = $_[1] }
sub display_string     { return $_[0]->{_display_string} || "LABEL" }
sub set_display_string { $_[0]->{_display_string} = $_[1] }
sub values     { return $_[0]->{_values}  }
sub set_values { $_[0]->{_values} = $_[1] }
sub labels     { return $_[0]->{_labels}  }
sub set_labels { $_[0]->{_labels} = $_[1] }
sub selection     { return $_[0]->{_selection}  }
sub set_selection { $_[0]->{_selection} = $_[1] }
sub selected_values     { return $_[0]->{_selected_values}  }
sub set_selected_values { $_[0]->{_selected_values} = $_[1] }
sub allows_no_selection     { return $_[0]->{_allows_no_selection}  }
sub set_allows_no_selection { $_[0]->{_allows_no_selection} = $_[1] }
sub any_string     { return $_[0]->{_any_string} || $_[0]->tag_attribute_for_key("anyString") }
sub set_any_string { $_[0]->{_any_string} = $_[1] }
sub any_value     { return $_[0]->{_any_value} || $_[0]->tag_attribute_for_key("anyValue") }
sub set_any_value { $_[0]->{_any_value} = $_[1] }
sub should_ignore_case     { return $_[0]->{_should_ignore_case}  }
sub set_should_ignore_case { $_[0]->{_should_ignore_case} = $_[1] }
sub should_ignore_accents     { return $_[0]->{_should_ignore_accents}  }
sub set_should_ignore_accents { $_[0]->{_should_ignore_accents} = $_[1] }
# sub allows_other     { return $_[0]->{_allows_other}  }
# sub set_allows_other { $_[0]->{_allows_other} = $_[1] }
# sub other_text     { return $_[0]->{_other_text}  }
# sub set_other_text { $_[0]->{_other_text} = $_[1] }
# sub other_value     { return $_[0]->{_other_value} || "OTHER" }
# sub set_other_value { $_[0]->{_other_value} = $_[1] }
# sub other_label     { return $_[0]->{_other_label} || "OTHER" }
# sub set_other_label { $_[0]->{_other_label} = $_[1] }
# sub other_alternate_key     { return $_[0]->{_other_alternate_key}  }
# sub set_other_alternate_key { $_[0]->{_other_alternate_key} = $_[1] }

1;