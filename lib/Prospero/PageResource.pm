package Prospero::PageResource;

use strict;
use base qw(
    Prospero::Object
);

sub stylesheet {
    my ( $class, $location, $dom_id ) = @_;
    return $class->new(
        location  => $location,
        dom_id    => $dom_id,
        mime_type => "text/css",
        type      => "stylesheet",
    );
}

sub javascript {
    my ( $class, $location ) = @_;
    return $class->new(
        location  => $location,
        mime_type => "text/javascript",
        type      => "javascript",
    );
}

sub alternateStylesheetNamed {
    my ( $class, $location, $name ) = @_;
    return $class->new(
        location  => $location,
        title     => $name,
        mime_type => "text/css",
        type      => "alternate stylesheet",
    );
}

sub location      { return $_[0]->{_location}   }
sub set_location  { $_[0]->{_location} = $_[1]  }
sub type          { return $_[0]->{_type}       }
sub set_type      { $_[0]->{_type} = $_[1]      }
sub mime_type     { return $_[0]->{_mime_type}  }
sub set_mime_type { $_[0]->{_mime_type} = $_[1] }
sub dom_id        { return $_[0]->{ dom_id}     }
sub set_dom_id    { $_[0]->{ dom_id} = $_[1]    }
sub title         { return $_[0]->{title}       }
sub set_title     { $_[0]->{title} = $_[1]      }
sub media         { return $_[0]->{media}       }
sub set_media     { $_[0]->{media} = $_[1]      }


# ------- this generates the tag to pull this resource in -------

sub tag {
    my ( $self ) = @_;
    # TODO:kd - generate cache buster
    #my $libVersion = IF::Application->systemConfigurationValueForKey("BUILD_VERSION");
    my $libVersion = 1;

    if ($self->type() eq "javascript") {
        return '<script type="'.$self->mime_type().'" src="'.$self->location().'?v='. $libVersion.'"></script>';
    } elsif ($self->type() eq "stylesheet" || $self->type() eq "alternate stylesheet") {
        my $media = $self->media() || "screen, print";
        my $link = '<link rel="'.$self->type().'" type="'.$self->mime_type().'" href="'.$self->location().'?v='. $libVersion .'" media="'.$media.'" title="'.$self->title().'"';
        $link .= ' id="' . $self->dom_id() . '" ' if $self->dom_id();
        $link .= ' />';
        return $link;
    }
    return "<!-- unknown resource type: ".$self->type()." location: ".$self->location()." -->";
}

1;
