package Prospero::Component::System::DateEditor;

use strict;
use warnings;

use base qw(
    Prospero::Component::System
    Prospero::Component::System::FormComponent
);

use DateTime;

sub set_date_string {
    my ( $self, $date_string ) = @_;

    # parse the string
    # TODO:kd - use date parsing if it's present

    my ( $year, $month, $day ) = $date_string =~ m!^(\d{4})-?(\d{2})-?(\d{2})$!;

    if ( $year && $month && $day ) {
        $self->set_year( $year );
        $self->set_month( $month );
        $self->set_day( $day );
    }
}
sub date_string {
    my ( $self ) = @_;
    return sprintf( "%04d-%02d-%02d", $self->year(), $self->month(), $self->day() );
}

sub init {
    my ( $self ) = @_;
    $self->SUPER::init(@_);
    $self->set_date_string( "0000-00-00" );
    $self->set_month_names( [qw(
        January February March April
        May June July August
        September October November December
    )]);
}

sub take_values_from_request {
    my ( $self, $request, $context ) = @_;

    $self->SUPER::take_values_from_request( $request, $context );

    #$self->setYear($context->formValueForKey("SYYYY_".$self->name()));
    #IF::Log::debug("Date is now ".$self->date());
    #$self->setMonth($context->formValueForKey("SMM_".$self->name()));
    #IF::Log::debug("Date is now ".$self->date());
    #$self->setDay($context->formValueForKey("SDD_".$self->name()));
    #IF::Log::debug("Date is now ".$self->date());
}

sub append_to_response {
    my ( $self, $response, $context ) = @_;

    #if ( $self->date_string() eq "0000-00-00" && $self->default_value() ) {
    #    $self->set($self->default_value());
    #}
    my $return_value = $self->SUPER::append_to_response( $response, $context );
    #$context->setTransactionValueForKey("1", "loaded-date-editor"); #TODO: fix this using RequestContext
    return $return_value;
}

sub days_as_strings {
    my ( $self ) = @_;

    my $days = [map {sprintf("%02d", $_)} (1..31)];
    if ($self->allows_no_selection()) {
        unshift (@$days, "");
    }
    return $days;
}

sub months_as_strings {
    my ( $self ) = @_;

    my $months_as_array = [];
    foreach my $index (1..12) {
        push (@$months_as_array, { value => sprintf("%02d", $index), display_string => $self->month_names()->[$index-1], });
    }
    if ($self->allows_no_selection()) {
        unshift (@$months_as_array, { value => "", display_string => "" });
    }
    return $months_as_array;
}

sub years_as_strings {
    my $self = shift;

    my $start_year = $self->start_year();
    my $end_year = $self->end_year();

    if ($end_year - $start_year > 100) {
        $end_year = $start_year + 100;
    }
    my @years = ($start_year..$end_year);

    if ($self->allows_no_selection()) {
        unshift (@years, "");
    }

    return \@years;
}

sub date {
    my $self = shift;
    if ($self->isUnixTimeFormat()) {
        return IF::Utility::unixTimeFromSQLDate($self->{DATE});
    }
    return $self->{DATE};
}

sub setDate {
    my $self = shift;
    my $date = shift;
    if ($date =~ /^[0-9]+$/) {
        $self->{DATE} = IF::Utility::sqlDateFromUnixTime($date);
        return;
    }
    return unless $date;
    $self->{DATE} = $date;
}

# just to keep it legal
sub value {
    my $self = shift;
    return $self->date();
}

sub setValue {
    my $self = shift;
    my $value = shift;
    $self->setDate($value);
}

sub year      { return $_[0]->{_year}  }
sub set_year  { $_[0]->{_year} = $_[1] }
sub month     { return $_[0]->{_month}  }
sub set_month { $_[0]->{_month} = $_[1] }
sub day       { return $_[0]->{_day}  }
sub set_day   { $_[0]->{_day} = $_[1] }
sub epoch     { return $_[0]->{_epoch}  }
sub set_epoch { $_[0]->{_epoch} = $_[1] }
sub default_value     { return $_[0]->{_default_value}  }
sub set_default_value { $_[0]->{_default_value} = $_[1] }
sub allows_no_selection     { return $_[0]->{_allows_no_selection}  }
sub set_allows_no_selection { $_[0]->{_allows_no_selection} = $_[1] }
sub should_show_today_link     { return $_[0]->{_should_show_today_link}  }
sub set_should_show_today_link { $_[0]->{_should_show_today_link} = $_[1] }
sub month_names     { return $_[0]->{_month_names}  }
sub set_month_names { $_[0]->{_month_names} = $_[1] }


sub start_year {
    my $self = shift;
    return $self->{_start_year} if $self->{_start_year};
    return $self->year() if $self->year() && $self->year() ne "0000";
    return $self->current_year();
}

sub set_start_year {
    my $self = shift;
    $self->{_start_year} = shift;
}

sub end_year {
    my $self = shift;
    return $self->{_end_year} if $self->{_end_year};
    return ($self->current_year() + 10);
}

sub set_end_year {
    my $self = shift;
    $self->{_end_year} = shift;
}

sub current_date {
    my $self = shift;
    unless ($self->{_current_date}) {
        $self->{_current_date} = DateTime->now();
    }
    return $self->{_current_date};
}

sub current_year {
    my $self = shift;
    return $self->current_date()->year();
}

sub current_month {
    my $self = shift;
    return $self->current_date()->month();
}

sub current_day {
    my $self = shift;
    return $self->current_date()->day();
}

sub bindings {
    my ( $self ) = @_;
    return $self->SUPER::bindings()->push_frame({
        year => {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_year" },
            list => q(years_as_strings),
            selection => q(year),
        },
        month => {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_month" },
            list => q(months_as_strings),
            selection => q(month),
            value => sub {'value'},
            display_string => sub {'display_string'},
        },
        day => {
            type => "Prospero::Component::System::PopUpMenu",
            name => sub { $_[0]->name()."_day" },
            list => q(days_as_strings),
            selection => q(day),
        },
    });
}

1;
