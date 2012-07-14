package Prospero::Component::System::URL;

use strict;
use base qw(
    Prospero::Component
);

#====================================
use Prospero::DictionaryStack;
use Prospero::Utility qw( array_from_object );
#use IF::Dictionary;
#use IF::Web::ActionLocator;
#====================================
use URI::Escape ();
use Encode ();

sub init {
    my ( $self ) = @_;

    #$self->setDirectAction();
    #$self->setTargetComponentName();
    $self->set_url();
    $self->set_query_dictionary({});
    $self->set_raw_query_dictionary({});
    $self->set_query_string();
    $self->set_should_suppress_query_dictionary( 0 );
    $self->{_query_dictionary_additions} = [];
    $self->{_query_dictionary_subtractions} = Prospero::DictionaryStack->new();
    $self->{_query_dictionary_replacements} = Prospero::DictionaryStack->new();
    return $self;
}

# sub action {
#     my ($self = shift;
#
#     return $self->{action} if $self->{action};
#
#     my $componentName = $self->targetComponentName();
#     my $directAction = $self->directAction();
#     if ($componentName eq "") {
#         $componentName = $self->rootComponent()->componentNameRelativeToSiteClassifier();
#         if ($self->parent()) {
#             my $pageContextNumber = $self->parent()->pageContextNumber();
#             if ($pageContextNumber != 1) {
#                 $directAction = $pageContextNumber."-".$directAction;
#             }
#         }
#     }
#
#     $componentName =~ s!::!/!g;
#     my $siteClassifierName = $self->siteClassifierName();
#     my $root     = $self->urlRoot();
#     my $language = $self->language();
#
#     my $al = IF::Web::ActionLocator->new();
#     $al->setUrlRoot($root);
#     $al->setSiteClassifierName($siteClassifierName);
#     $al->setLanguage($language);
#     $al->setTargetComponentName($componentName);
#     $al->setDirectAction($directAction);
#
#     my $application = $self->context() ? $self->context()->application() : IF::Application->defaultApplication();
#     my $module = $application->moduleInContextForComponentNamed($self->context(), $componentName);
#     if ($module) {
#         my $ou = $module->urlFromActionLocatorAndQueryDictionary($al, $self->queryDictionaryAsHash());
#         # testing:
#         #my $iu = $module->urlFromIncomingUrl($ou);
#         #IF::Log::debug("That maps back to $iu");
#
#         $self->setShouldSuppressQueryDictionary(1) unless $ou eq $al->asAction();
#         return $ou;
#     } else {
#         return $al->asAction();
#     }
# }

sub action { return $_[0]->{_action} }
sub set_action {
    my ( $self, $value ) = @_;
    $self->{_action} = $value;
}

sub query_string     { return $_[0]->{_query_string}  }
sub set_query_string { $_[0]->{_query_string} = $_[1] }
sub server     { return $_[0]->{_server}  }
sub set_server { $_[0]->{_server} = $_[1] }

sub protocol {
    my ( $self ) = @_;
    return $self->{_protocol} if $self->{_protocol};
    return "http";
}

sub set_protocol {
    my ( $self, $value ) = @_;
    $self->{_protocol} = $value;
}

sub url     { return $_[0]->{_url}  }
sub set_url { $_[0]->{_url} = $_[1] }

sub should_ensure_default_protocol     { return $_[0]->{_should_ensure_default_protocol}  }
sub set_should_ensure_default_protocol { $_[0]->{_should_ensure_default_protocol} = $_[1] }
sub anchor     { return $_[0]->{_anchor}  }
sub set_anchor { $_[0]->{_anchor} = $_[1] }


sub has_query_dictionary {
    my ( $self ) = @_;
    return 1 if ( $self->query_dictionary()
               && scalar @{ $self->query_dictionary()->keys() } > 0 );
    return 1 if ( scalar @{ $self->{_query_dictionary_additions} } > 0);
    return 1 if ( scalar @{ $self->{_query_dictionary_replacements}->keys() } );
    return 1 if length( $self->{_query_string} );
    return 1 if ( $self->raw_query_dictionary()
               && scalar keys %{ $self->raw_query_dictionary() } );
    return 0;
}

sub query_dictionary {
    my $self = shift;
    return $self->{_query_dictionary};
}

sub set_query_dictionary {
    my ($self, $qd) = @_;
    # dopey kyle: make a copy before changing this, seeing as
    # how it's BOUND IN from outside!
    my $qd_copy = $qd->as_flat();
    $self->{_query_dictionary} = $qd_copy;
    # expand the values and evaluate in the context of the parent:
    my $parent = $self->parent();
    $qd_copy->push_frame();
    foreach my $key (@{ $qd_copy->keys()}) {
        my $value = $qd_copy->value_for_key( $key );
        if ( ref( $value ) eq "CODE" ) {
            $qd_copy->set_value_for_key( $value->( $parent ), $key );
        } else {
            $qd_copy->set_value_for_key( $parent->value_for_key( $value ), $key );
        }
    }
}

sub raw_query_dictionary     { return $_[0]->{_raw_query_dictionary}  }
sub set_raw_query_dictionary { $_[0]->{_raw_query_dictionary} = $_[1] }

sub query_dictionary_key_value_pairs {
    my ( $self ) = @_;

    my $key_value_pairs = [];
    my $used_keys = Prospero::DictionaryStack->new();

    # first we do the additions:
    foreach my $addition (@{$self->{_query_dictionary_additions}}) {
        my $key = $addition->{NAME};
        next if ($self->should_suppress_query_dictionary_key($key));
        my $value = $self->{_query_dictionary_replacements}->value_for_key($key) ||
                    $addition->{VALUE};
        push @$key_value_pairs, { NAME => $key, VALUE => $value};
        $used_keys->set_value_for_key(1, $key);
    }

    # if there's a query string, unpack it and use it instead of the query dictionary
    my $qd = $self->query_dictionary();
    if ($self->query_string()) {
        $qd = Prospero::DictionaryStack->new()->init_with_query_string($self->{_query_string});
    }
    my $rqd = $self->raw_query_dictionary();

    # next we go through the query dictionary itself
    # and skip values that are "subtracted".  We also
    # replace values that are "replaced"
    foreach my $hash ($qd, $rqd) {
        foreach my $key (keys %$hash) {
            next if ($self->should_suppress_query_dictionary_key($key));
            my $value = $self->{_query_dictionary_replacements}->value_for_key($key) ||
                        $hash->{$key};

            # handle the multiple values:
            my $values = array_from_object( $value );

            foreach my $v (@$values) {
                push @$key_value_pairs, {
                    NAME => $key,
                    VALUE => $v,
                };
            }
            $used_keys->set_value_for_key(1, $key);
        }
    }


    # Lastly, we make sure there are no unused values in the "replacements"
    foreach my $key (@{$self->{_query_dictionary_replacements}->keys()}) {
        next if ( $used_keys->{$key} );
        my $values = array_from_object( $self->{_query_dictionary_replacements}->value_for_key( $key) );
        foreach my $v (@$values) {
            push @$key_value_pairs, {
                NAME => $key,
                VALUE => $v,
            };
        }
    }
    return $key_value_pairs;
}

sub query_dictionary_as_query_string {
    my $self = shift;
    my $qd = $self->query_dictionary_key_value_pairs();
    my $qstr = [];
    foreach my $kvp (@$qd) {
        my $k = $kvp->{NAME};
        my $v = $self->escape_query_string_value($kvp->{VALUE});
        push @$qstr,"$k=$v";
    }
    return join ('&', @$qstr);
}

sub query_dictionary_as_hash {
    my $self = shift;
    my $qd = $self->query_dictionary_key_value_pairs();
    my $qdh = {};
    foreach my $kvp (@$qd) {
        $qdh->{$kvp->{NAME}} = $kvp->{VALUE};
    }
    return $qdh;
}


sub should_suppress_query_dictionary     { return $_[0]->{_should_suppress_query_dictionary}  }
sub set_should_suppress_query_dictionary { $_[0]->{_should_suppress_query_dictionary} = $_[1] }

sub should_suppress_query_dictionary_key {
    my ($self, $key) = @_;
    return 1 if ($self->{_query_dictionary_subtractions}->has_value_for_key( $key ));
    return 0;
}

# a binding starting with "^" will direct this component
# to REPLACE the query dictionary entry with that key with the specified value.
# a binding starting with "+" will direct this component
# to ADD the key/value pair to the query dictionary
# a binding starting with "-" will direct this component
# to REMOVE that key/value pair from the query dictionary (the value is ignored)

sub set_value_for_key {
    my ( $self, $value, $key ) = @_;
    unless ($key =~ /^(\^|\+|\-)(.*)$/) {
        return $self->SUPER::set_value_for_key($value, $key);
    }
    my $action = $1;
    $key = $2;
    if ($action eq "+") {
        my $values = array_from_object( $value );
        foreach my $v (@$values) {
            push @{ $self->{_query_dictionary_additions} }, { NAME => $key, VALUE => $v };
        }
        return;
    } elsif ($action eq "-") {
        $self->{_query_dictionary_subtractions}->set_value_for_key("1", $key);
        return;
    } elsif ($action eq "^") {
        $self->{_query_dictionary_replacements}->set_value_for_key($value, $key);
        return;
    }
}

sub escape_query_string_value {
    my ($self, $string) = @_;
    if (Encode::is_utf8($string)) {
        return URI::Escape::uri_escape_utf8($string);
    } else {
        return URI::Escape::uri_escape($string);
    }
}

# This has been unrolled to speed it up; do not be tempted to do this
# anywhere else!

sub as_string {
    my $self = shift;
    my $html;

    if ($self->url()) {
        if ($self->should_ensure_default_protocol()) {
            # If we don't have the :// of the protocol and it's not relative meaning begins with /...
            unless ($self->url() =~ m|://| || $self->url() =~ m|^/|) {
                push @$html, "http://";
            }
        }
        push @$html, $self->url();
    } else {
        if ($self->server()) {
            if ($self->protocol()) {
                push @$html,$self->protocol(),"://";
            } else {
                push @$html, "http://";
            }

            push @$html, $self->server();
        }

        push @$html, $self->action();
    }

    if ($self->has_query_dictionary()) {
        my $qs = "";
        my $is_first = 1;
        unless ($self->should_suppress_query_dictionary()) {
            foreach my $kvPair (@{$self->query_dictionary_key_value_pairs()}) {
                $qs .= "&" unless $is_first;
                $is_first = 0;

                $qs .= $self->escape_query_string_value( $kvPair->{NAME} );
                $qs .= "=";
                $qs .= $self->escape_query_string_value( $kvPair->{VALUE} );
            }
            push ( @$html, "?", $qs ) if $qs;
        }
    }

    if ($self->anchor()) {
        push @$html, '#', $self->anchor();
    }
    return join( '', @$html );
}


sub append_to_response {
    my ( $self, $response, $context ) = @_;

    if ( ref($self) eq "Prospero::Component::System::URL" ) {
        $response->set_content( $self->asString() );
    } else {
        $self->SUPER::append_to_response($response, $context);
    }
    $self->init(); # Clear this instance so it can be re-used next time
    return;
}

1;
