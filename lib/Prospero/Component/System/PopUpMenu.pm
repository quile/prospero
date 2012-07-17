package Prospero::Component::System::PopUpMenu;

use strict;
use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

use Prospero::PageResource;
use Text::Unaccent;

sub required_page_resources {
    my ( $self ) = @_;
    return [
        Prospero::PageResource->javascript("/if-static/javascript/IF/PopUpMenu.js"),
    ];
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );

    $self->set_selection( $request->param( $self->name() ) );

    if ( $self->allows_other() ) {
        if ( $self->selection() eq $self->other_value() ) {
            if ($self->other_alternate_key()) {
                $self->set_value_for_key( $self->other_text(), "root_component." . $self->other_alternate_key());
            } else {
                $self->set_selection( $self->other_text() );
            }

        }
    }
    $self->reset_values();
}

sub reset_value {
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
        return $item->value_for_key( $self->value_for_key("display_string") );
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
        return $item->value_for_key( $self->value_for_key("VALUE") );
    }
    if ( ref($item) eq "HASH" ) {
        my $key = $self->value_for_key("value");
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

    if (UNIVERSAL::can($item, "valueForKey")) {
        $value = $item->valueForKey($self->valueForKey("VALUE"));
    } elsif (IF::Dictionary::isHash($item) && exists ($item->{$self->valueForKey("VALUE")})) {
        $value = $item->{$self->valueForKey("VALUE")};
    } else {
        $value = $item;
    }

    return 0 unless $value ne "";
    return 0 unless (IF::Array::isArray($self->valueForKey("SELECTED_VALUES")));
    #TODO: Optimise this by hashing it
    foreach my $selectedValue (@{$self->valueForKey("SELECTED_VALUES")}) {
        unless (ref $selectedValue) {
            #IF::Log::debug("Checking ($selectedValue, $value) to see if it's selected");
            #IF::Log::debug("Should ignore case ".$self->shouldIgnoreCase()." - Should ignore accents ".$self->shouldIgnoreAccents()." - Value is $value - Selected value is $selectedValue");
            return 1 if $self->valuesAreEqual($selectedValue, $value);

            # this could be optimised:
            if ($selectedValue =~ /^[0-9\.]+$/ &&
                $value =~ /^[0-9\.]+$/ &&
                $selectedValue == $value) {
                return 1;
            }
            next;
        }
        if (UNIVERSAL::can($selectedValue, "valueForKey")) {
            return 1 if $self->valuesAreEqual($selectedValue->valueForKey($self->valueForKey("VALUE")), $value);
        } else {
            return 1 if $self->valuesAreEqual($selectedValue->{$self->valueForKey("VALUE")}, $value);
        }
    }
    return 0;
}

sub values_are_equal {
    my ( $self, $a, $b ) = @_;

    if ( $self->should_ignore_accents() ) {
        $a = unac_string( "utf-8", $a );
        $b = unac_string( "utf-8", $b );
    }

    if ( $self->should_ignore_case() ) {
        $a = lc( $a );
        $b = lc( $b );
    }

    return ($a eq $b);
}

# sub setValues {
#     my $self = shift;
#     $self->{VALUES} = shift;
#
#     if ($self->{LABELS}) {
#         $self->{LIST} = $self->listFromLabelsAndValues();
#     }
# }
#
# sub setLabels {
#     my $self = shift;
#     $self->{LABELS} = shift;
#
#     if ($self->{VALUES}) {
#         $self->{LIST} = $self->listFromLabelsAndValues();
#     }
# }
#
# sub listFromLabelsAndValues {
#     my $self = shift;
#
#     return [] unless $self->{VALUES} && $self->{LABELS};
#
#     my $list = [];
#     foreach my $value (@{$self->{VALUES}}) {
#         push (@$list, { VALUE => $value, LABEL => $self->{LABELS}->{$value} });
#     }
#     return $list;
# }







sub name     { return $_[0]->{_name} || $_[0]->node_id() }
sub set_name { $_[0]->{_name} = $_[1] }

sub list {
    my $self = shift;
    unless ($self->{_list}) {
        my $list;
        if ($self->values() &&
            $self->value() &&
            $self->displayString()) {
            $list = [];
            foreach my $value (@{$self->values()}) {
                push (@$list, { $self->value() => $value, $self->displayString() => $self->labels()->{$value} });
            }
        } else {
            $list = [];
            foreach my $item (@{$self->{LIST}}) {
                push (@$list, $item);
            }
        }

        if ($self->allowsNoSelection()) {
            if ($self->value() && $self->displayString()) {
                unshift (@$list, { $self->value() => $self->anyValue(), $self->displayString() => $self->anyString() });
            } else {
                unshift (@$list, ''); # TODO this is bogus but the only way to ensure that an empty value gets sent in this case
            }
        }

        if ($self->allowsOther()) {
            # Check to see if other is already in the list...
            my $hasOther = 0;
            foreach my $item (@$list) {
                if (ref($item)) {
                    if ($item->{$self->value()} eq $self->otherValue()) {
                        $hasOther = 1;
                        last;
                    }
                } else {
                    if ($item eq $self->otherValue()) {
                        $hasOther = 1;
                        last;
                    }
                }
            }
            # ...Only add the other value if it doesn't exist.
            unless ($hasOther) {
                if ($self->value() && $self->displayString()) {
                    push (@$list, {$self->value() => $self->otherValue(), $self->displayString() => $self->otherLabel()});
                } else {
                    push (@$list, $self->otherValue());
                }
            }
        }
        $self->{_list} = $list;
    }
    return $self->{_list};
}

sub setList {
    my $self = shift;
    $self->{_list} = shift;
}

sub values     { return $_[0]->{_values}  }
sub set_values { $_[0]->{_values} = $_[1] }
sub labels     { return $_[0]->{_labels}  }
sub set_labels { $_[0]->{_labels} = $_[1] }
sub selection     { return $_[0]->{_selection}  }
sub set_selection { $_[0]->{_selection} = $_[1] }
sub allows_no_selection     { return $_[0]->{_allows_no_selection}  }
sub set_allows_no_selection { $_[0]->{_allows_no_selection} = $_[1] }
sub any_string     { return $_[0]->{_any_string} || $_[0]->tag_attribute_for_key("anyString") }
sub set_any_string { $_[0]->{_any_string} = $_[1] }
sub should_ignore_case     { return $_[0]->{_should_ignore_case}  }
sub set_should_ignore_case { $_[0]->{_should_ignore_case} = $_[1] }
sub should_ignore_accents     { return $_[0]->{_should_ignore_accents}  }
sub set_should_ignore_accents { $_[0]->{_should_ignore_accents} = $_[1] }
sub allows_other     { return $_[0]->{_allows_other}  }
sub set_allows_other { $_[0]->{_allows_other} = $_[1] }
sub other_text     { return $_[0]->{_other_text}  }
sub set_other_text { $_[0]->{_other_text} = $_[1] }
sub other_value     { return $_[0]->{_other_value} || "OTHER" }
sub set_other_value { $_[0]->{_other_value} = $_[1] }
sub other_label     { return $_[0]->{_other_label} || "OTHER" }
sub set_other_label { $_[0]->{_other_label} = $_[1] }
sub other_alternate_key     { return $_[0]->{_other_alternate_key}  }
sub set_other_alternate_key { $_[0]->{_other_alternate_key} = $_[1] }

1;