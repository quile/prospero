package Unit::Component;

use strict;

use base qw( Test::Class );
use Test::More;

use Prospero::DictionaryStack;

sub test_push_pop : Tests {
    my ( $self ) = @_;

    my $d = Prospero::DictionaryStack->new();
    ok( $d, "Instantiated dictionary" );

    $d->set_value_for_key( "first", "banana" );

    ok( $d->value_for_key( "banana" ) eq "first", "Set key directly." );
    ok( scalar @{ $d->frames() } == 1, "Dictionary has one frame" );
    $d->pop_frame();
    ok( scalar @{ $d->frames() } == 1, "Dictionary has one frame" );
    ok( $d->value_for_key( "banana" ) eq "first", "Value still set correctly." );

    $d->push_frame();
    ok( scalar @{ $d->frames() } == 2, "Dictionary has two frames" );
    ok( $d->value_for_key( "banana" ), "Value still set correctly, frame cascades correctly." );

    $d->set_value_for_key( "second", "banana" );
    ok( $d->value_for_key( "banana" ) eq "second", "Key now has new value." );

    $d->set_value_for_key( "third", "mango" );
    ok( $d->value_for_key( "mango" ) eq "third", "Key now has new value." );

    ok( exists $d->frames()->[0]->{banana}, "'banana' exists in first frame" );
    ok( exists $d->frames()->[0]->{mango}, "'mango' exists in first frame" );
    ok( ! exists $d->frames()->[1]->{mango}, "'mango' doesn't exist in second frame" );

    $d->pop_frame();
    ok( ! defined $d->value_for_key( "mango" ), "mango no longer exists" );
    ok( $d->value_for_key( "banana" ) eq "first", "banana value is back to first value" );
}

sub test_keys : Tests {
    my ( $self ) = @_;

    my $d = Prospero::DictionaryStack->new();

    $d->set_value_for_key( "first", "banana" );
    $d->push_frame();
    $d->set_value_for_key( "second", "banana" );
    $d->set_value_for_key( "third", "mango" );
    $d->push_frame();
    $d->set_value_for_key( "fourth", "mango" );
    $d->set_value_for_key( "fifth", "papaya" );

    my $keys = $d->keys();
    is_deeply( [ sort @$keys ], [ "banana", "mango", "papaya" ], "Keys OK" );

    $d->pop_frame();
    $keys = $d->keys();
    is_deeply( [ sort @$keys ], [ "banana", "mango" ], "Keys OK" );

    $d->pop_frame();
    $keys = $d->keys();
    is_deeply( [ sort @$keys ], [ "banana" ], "Keys OK" );

    $d->pop_frame();
    $keys = $d->keys();
    is_deeply( [ sort @$keys ], [ "banana" ], "Keys OK" );

    $d->reset_frames();
    $keys = $d->keys();
    is_deeply( $keys, [], "Keys OK" );
}

1;