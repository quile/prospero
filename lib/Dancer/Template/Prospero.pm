package Dancer::Template::Prospero;

use Prospero::Plugin::TT2::Engine;
use Prospero::Utility qw( array_from_object );

use Dancer::Config 'setting';
use Dancer::ModuleLoader;
use Dancer::Exception qw(:all);

use base qw( Dancer::Template::TemplateToolkit );

use Data::Dumper;

my $_engine;

sub init {
    my ($self) = @_;

    my $class = $self->config->{subclass} || "Prospero::Plugin::TT2::Engine";
    raise core_template => "$class is needed by Dancer::Template::Prospero"
      if !$class->can("process") and !Dancer::ModuleLoader->load($class);

    my $charset = setting('charset') || '';
    my @encoding = length($charset) ? ( ENCODING => $charset ) : ();

    my $tt_config = {
        ANYCASE  => 0,
        ABSOLUTE => 1,
        @encoding,
        %{$self->config},
    };

    my $start_tag = $self->config->{start_tag} || '<%';
    my $stop_tag =
         $self->config->{stop_tag}
      || $self->config->{end_tag}
      || '%>';

    $tt_config->{START_TAG} = $start_tag if $start_tag ne '[%';
    $tt_config->{END_TAG}   = $stop_tag  if $stop_tag  ne '%]';

    if ( $tt_config->{INCLUDE_PATH} ) {
        $tt_config->{INCLUDE_PATH} = array_from_object( $tt_config->{INCLUDE_PATH} );
        my $views = array_from_object( setting('views') );
        push @{$tt_config->{INCLUDE_PATH}}, @$views;
    } else {
        $tt_config->{INCLUDE_PATH} = setting('views');
    }

    $_engine = $class->new($tt_config);
}

sub _engine {
    return $_engine;
}

1;