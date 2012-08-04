package Prospero::Component::System::TimeEditor;

use strict;
use warnings;

use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

use DateTime;

sub hours       { return $_[0]->{_hours}    }
sub set_hours   { $_[0]->{_hours} = $_[1]   }
sub minutes     { return $_[0]->{_minutes}  }
sub set_minutes { $_[0]->{_minutes} = $_[1] }
sub seconds     { return $_[0]->{_seconds}  }
sub set_seconds { $_[0]->{_seconds} = $_[1] }
sub is_twenty_four_hour     { return $_[0]->{_is_twenty_four_hour}  }
sub set_is_twenty_four_hour { $_[0]->{_is_twenty_four_hour} = $_[1] }
sub should_show_seconds     { return $_[0]->{_should_show_seconds}  }
sub set_should_show_seconds { $_[0]->{_should_show_seconds} = $_[1] }
sub allows_no_selection     { return $_[0]->{_allows_no_selection}  }
sub set_allows_no_selection { $_[0]->{_allows_no_selection} = $_[1] }
sub starts_empty     { return $_[0]->{_starts_empty}  }
sub set_starts_empty { $_[0]->{_starts_empty} = $_[1] }
sub should_show_now_link     { return $_[0]->{_should_show_now_link}  }
sub set_should_show_now_link { $_[0]->{_should_show_now_link} = $_[1] }

# sub take_values_from_request {
#     my ( $self, $request, $context ) = @_;
#
#     $self->SUPER::take_values_from_request( $request, $context );
#
#     # my $hours = $context->formValueForKey("SHH_".$self->name());
#     # if ($context->formValueForKey("SAP_".$self->name()) eq "pm" &&
#     #     $hours < 12) {
#     #     $hours += 12;
#     # } elsif ($context->formValueForKey("SAP_".$self->name()) eq "am" &&
#     #     $hours == 12) {
#     #     $hours = 0;
#     # }
#     # $self->setHours($hours);
#     # $self->setMinutes($context->formValueForKey("SMM_".$self->name()));
#     # $self->setSeconds($context->formValueForKey("SSS_".$self->name()));
# }

sub set_time_string {
    my ( $self, $time_string ) = @_;

    my ( $hours, $minutes, $seconds ) = $time_string =~ m!^(\d{2}):?(\d{2}):?(\d{2})?!;

    if ( defined $hours && defined $minutes ) {
        $self->set_hours( $hours );
        $self->set_minutes( $minutes );
        $self->set_seconds( $seconds );
    }
}

sub time_string {
    my ( $self ) = @_;
    return sprintf( "%02d:%02d:%02d", $self->hours(), $self->minutes(), $self->seconds() );
}

sub am_pm {
    my ( $self ) = @_;
    return "pm" if ( $self->hours() > 11 );
    return "am";
}

sub hours_for_selection {
    my $self = shift;
    my $hours = [1..12];
    if ( $self->is_twenty_four_hour() ) {
        $hours = [0..23];
    }
    if ( $self->allows_no_selection() ) {
        unshift (@$hours, "");
    }
    return $hours;
}

sub minutes_for_selection {
    my $self = shift;
    my $minutes = [ map {sprintf("%02d", $_)} (0..59) ];
    if ( $self->allows_no_selection() ) {
        unshift (@$minutes, "");
    }
    return $minutes;
}

sub seconds_for_selection {
    my ( $self ) = shift;
    my $seconds = [0 .. 59];
    if ( $self->allows_no_selection() ) {
        unshift @$seconds, "";
    }
    return $seconds;
}

sub current_time {
    my $self = shift;
    unless ($self->{_current_time}) {
        $self->{_current_time} = DateTime->now();
    }
    return $self->{_current_time};
}

sub current_hours {
    my $self = shift;
    my $hours = $self->current_time()->hour();
    return $hours if ($self->is_twenty_four_hour());
    $hours = $hours % 12;
    return $hours unless $hours == 0;
    return 12;
}

sub current_minute {
    my $self = shift;
    return $self->current_time()->minute();
}

sub current_second {
    my $self = shift;
    return $self->current_time()->second();
}

sub current_am_pm {
    my $self = shift;
    if ( $self->current_time()->hour() >= 12 ) {
        return "pm";
    }
    return "am";
}

sub bindings {
    my ( $self ) = @_;
    return $self->SUPER::bindings()->push_frame({
        hours => {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_hour" },
            list => q(hours_for_selection),
            selection => q(hours),
        },
        minutes=> {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_minute" },
            list => q(minutes_for_selection),
            selection => q(minutes),
        },
        seconds => {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_second" },
            list => q(seconds_for_selection),
            selection => q(seconds),
        },
        am_pm => {
            type => "Prospero::Component::System::RadioButtonGroup",
            name => sub { $_[0]->name()."_am_pm" },
            list => sub {[ "am", "pm", ]},
            selection => q(am_pm),
        },
    });
}

1;
