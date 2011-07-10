package SDL::ConfigData;
use strict;
my $arrayref = eval do {local $/; <DATA>}
  or die "Couldn't load ConfigData data: $@";
close DATA;
my ($config, $features, $auto_features) = @$arrayref;

sub config { $config->{$_[1]} }

sub set_config { $config->{$_[1]} = $_[2] }
sub set_feature { $features->{$_[1]} = 0+!!$_[2] }  # Constrain to 1 or 0

sub auto_feature_names { grep !exists $features->{$_}, keys %$auto_features }

sub feature_names {
  my @features = (keys %$features, auto_feature_names());
  @features;
}

sub config_names  { keys %$config }

sub write {
  my $me = __FILE__;
  require IO::File;

  # Can't use Module::Build::Dumper here because M::B is only a
  # build-time prereq of this module
  require Data::Dumper;

  my $mode_orig = (stat $me)[2] & 07777;
  chmod($mode_orig | 0222, $me); # Make it writeable
  my $fh = IO::File->new($me, 'r+') or die "Can't rewrite $me: $!";
  seek($fh, 0, 0);
  while (<$fh>) {
    last if /^__DATA__$/;
  }
  die "Couldn't find __DATA__ token in $me" if eof($fh);

  seek($fh, tell($fh), 0);
  my $data = [$config, $features, $auto_features];
  $fh->print( 'do{ my '
	      . Data::Dumper->new([$data],['x'])->Purity(1)->Dump()
	      . '$x; }' );
  truncate($fh, tell($fh));
  $fh->close;

  chmod($mode_orig, $me)
    or warn "Couldn't restore permissions on $me: $!";
}

sub feature {
  my ($package, $key) = @_;
  return $features->{$key} if exists $features->{$key};

  my $info = $auto_features->{$key} or return 0;

  # Under perl 5.005, each(%$foo) isn't working correctly when $foo
  # was reanimated with Data::Dumper and eval().  Not sure why, but
  # copying to a new hash seems to solve it.
  my %info = %$info;

  require Module::Build;  # XXX should get rid of this
  while (my ($type, $prereqs) = each %info) {
    next if $type eq 'description' || $type eq 'recommends';

    my %p = %$prereqs;  # Ditto here.
    while (my ($modname, $spec) = each %p) {
      my $status = Module::Build->check_installed_status($modname, $spec);
      if ((!$status->{ok}) xor ($type =~ /conflicts$/)) { return 0; }
      if ( ! eval "require $modname; 1" ) { return 0; }
    }
  }
  return 1;
}


=head1 NAME

SDL::ConfigData - Configuration for SDL

=head1 SYNOPSIS

  use SDL::ConfigData;
  $value = SDL::ConfigData->config('foo');
  $value = SDL::ConfigData->feature('bar');

  @names = SDL::ConfigData->config_names;
  @names = SDL::ConfigData->feature_names;

  SDL::ConfigData->set_config(foo => $new_value);
  SDL::ConfigData->set_feature(bar => $new_value);
  SDL::ConfigData->write;  # Save changes


=head1 DESCRIPTION

This module holds the configuration data for the C<SDL>
module.  It also provides a programmatic interface for getting or
setting that configuration data.  Note that in order to actually make
changes, you'll have to have write access to the C<SDL::ConfigData>
module, and you should attempt to understand the repercussions of your
actions.


=head1 METHODS

=over 4

=item config($name)

Given a string argument, returns the value of the configuration item
by that name, or C<undef> if no such item exists.

=item feature($name)

Given a string argument, returns the value of the feature by that
name, or C<undef> if no such feature exists.

=item set_config($name, $value)

Sets the configuration item with the given name to the given value.
The value may be any Perl scalar that will serialize correctly using
C<Data::Dumper>.  This includes references, objects (usually), and
complex data structures.  It probably does not include transient
things like filehandles or sockets.

=item set_feature($name, $value)

Sets the feature with the given name to the given boolean value.  The
value will be converted to 0 or 1 automatically.

=item config_names()

Returns a list of all the names of config items currently defined in
C<SDL::ConfigData>, or in scalar context the number of items.

=item feature_names()

Returns a list of all the names of features currently defined in
C<SDL::ConfigData>, or in scalar context the number of features.

=item auto_feature_names()

Returns a list of all the names of features whose availability is
dynamically determined, or in scalar context the number of such
features.  Does not include such features that have later been set to
a fixed value.

=item write()

Commits any changes from C<set_config()> and C<set_feature()> to disk.
Requires write access to the C<SDL::ConfigData> module.

=back


=head1 AUTHOR

C<SDL::ConfigData> was automatically created using C<Module::Build>.
C<Module::Build> was written by Ken Williams, but he holds no
authorship claim or copyright claim to the contents of C<SDL::ConfigData>.

=cut


__DATA__
do{ my $x = [
  {
    'subsystems' => {
      'MixerEffects' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/Effects.xs',
          'from' => 'src/Mixer/Effects.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'ImageFilter' => {
        'file' => {
          'to' => 'lib/SDL/GFX/ImageFilter.xs',
          'from' => 'src/GFX/ImageFilter.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_imagefilter'
        ]
      },
      'Video' => {
        'file' => {
          'to' => 'lib/SDL/Video.xs',
          'from' => 'src/Core/Video.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Surface' => {
        'file' => {
          'to' => 'lib/SDL/Surface.xs',
          'from' => 'src/Core/objects/Surface.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'SFont' => {
        'file' => {
          'to' => 'lib/SDLx/SFont.xs',
          'from' => 'src/SDLx/SFont.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_image'
        ]
      },
      'MixerSamples' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/Samples.xs',
          'from' => 'src/Mixer/Samples.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'TTF_Font' => {
        'file' => {
          'to' => 'lib/SDL/TTF/Font.xs',
          'from' => 'src/TTF/objects/Font.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_ttf'
        ]
      },
      'CD' => {
        'file' => {
          'to' => 'lib/SDL/CD.xs',
          'from' => 'src/Core/objects/CD.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'FPSManager' => {
        'file' => {
          'to' => 'lib/SDL/GFX/FPSManager.xs',
          'from' => 'src/GFX/FPSManager.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_framerate'
        ]
      },
      'ValidateX' => {
        'file' => {
          'to' => 'lib/SDLx/Validate.xs',
          'from' => 'src/SDLx/Validate.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'TTF' => {
        'file' => {
          'to' => 'lib/SDL/TTF.xs',
          'from' => 'src/TTF/TTF.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_ttf'
        ]
      },
      'MixerGroups' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/Groups.xs',
          'from' => 'src/Mixer/Groups.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'BlitFunc' => {
        'file' => {
          'to' => 'lib/SDL/GFX/BlitFunc.xs',
          'from' => 'src/GFX/BlitFunc.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_blitfunc'
        ]
      },
      'Cursor' => {
        'file' => {
          'to' => 'lib/SDL/Cursor.xs',
          'from' => 'src/Core/objects/Cursor.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Mixer' => {
        'file' => {
          'to' => 'lib/SDL/Mixer.xs',
          'from' => 'src/Mixer/Mixer.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'RWOps' => {
        'file' => {
          'to' => 'lib/SDL/RWOps.xs',
          'from' => 'src/Core/objects/RWOps.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Version' => {
        'file' => {
          'to' => 'lib/SDL/Version.xs',
          'from' => 'src/Core/objects/Version.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Primitives' => {
        'file' => {
          'to' => 'lib/SDL/GFX/Primitives.xs',
          'from' => 'src/GFX/Primitives.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_primitives'
        ]
      },
      'Events' => {
        'file' => {
          'to' => 'lib/SDL/Events.xs',
          'from' => 'src/Core/Events.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Rotozoom' => {
        'file' => {
          'to' => 'lib/SDL/GFX/Rotozoom.xs',
          'from' => 'src/GFX/Rotozoom.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_rotozoom'
        ]
      },
      'PixelFormat' => {
        'file' => {
          'to' => 'lib/SDL/PixelFormat.xs',
          'from' => 'src/Core/objects/PixelFormat.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Framerate' => {
        'file' => {
          'to' => 'lib/SDL/GFX/Framerate.xs',
          'from' => 'src/GFX/Framerate.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_framerate'
        ]
      },
      'Rect' => {
        'file' => {
          'to' => 'lib/SDL/Rect.xs',
          'from' => 'src/Core/objects/Rect.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Time' => {
        'file' => {
          'to' => 'lib/SDL/Time.xs',
          'from' => 'src/Core/Time.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'LayerX' => {
        'file' => {
          'to' => 'lib/SDLx/Layer.xs',
          'from' => 'src/SDLx/Layer.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_image'
        ]
      },
      'StateX' => {
        'file' => {
          'to' => 'lib/SDLx/Controller/State.xs',
          'from' => 'src/SDLx/Controller/State.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'CDROM' => {
        'file' => {
          'to' => 'lib/SDL/CDROM.xs',
          'from' => 'src/Core/CDROM.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Color' => {
        'file' => {
          'to' => 'lib/SDL/Color.xs',
          'from' => 'src/Core/objects/Color.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'InterfaceX' => {
        'file' => {
          'to' => 'lib/SDLx/Controller/Interface.xs',
          'from' => 'src/SDLx/Controller/Interface.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'CDTrack' => {
        'file' => {
          'to' => 'lib/SDL/CDTrack.xs',
          'from' => 'src/Core/objects/CDTrack.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'MultiThread' => {
        'file' => {
          'to' => 'lib/SDL/MultiThread.xs',
          'from' => 'src/Core/MultiThread.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Mouse' => {
        'file' => {
          'to' => 'lib/SDL/Mouse.xs',
          'from' => 'src/Core/Mouse.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'TimerX' => {
        'file' => {
          'to' => 'lib/SDLx/Controller/Timer.xs',
          'from' => 'src/SDLx/Timer.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'MixerChannels' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/Channels.xs',
          'from' => 'src/Mixer/Channels.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'Joystick' => {
        'file' => {
          'to' => 'lib/SDL/Joystick.xs',
          'from' => 'src/Core/Joystick.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'MixMusic' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/MixMusic.xs',
          'from' => 'src/Mixer/objects/MixMusic.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'Palette' => {
        'file' => {
          'to' => 'lib/SDL/Palette.xs',
          'from' => 'src/Core/objects/Palette.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Event' => {
        'file' => {
          'to' => 'lib/SDL/Event.xs',
          'from' => 'src/Core/objects/Event.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'MixerMusic' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/Music.xs',
          'from' => 'src/Mixer/Music.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'Pango' => {
        'file' => {
          'to' => 'lib/SDL/Pango.xs',
          'from' => 'src/Pango/Pango.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_Pango'
        ]
      },
      'SDL' => {
        'file' => {
          'to' => 'lib/SDL_perl.xs',
          'from' => 'src/SDL.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Image' => {
        'file' => {
          'to' => 'lib/SDL/Image.xs',
          'from' => 'src/Image.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_image'
        ]
      },
      'Overlay' => {
        'file' => {
          'to' => 'lib/SDL/Overlay.xs',
          'from' => 'src/Core/objects/Overlay.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Context' => {
        'file' => {
          'to' => 'lib/SDL/Pango/Context.xs',
          'from' => 'src/Pango/objects/Context.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_Pango'
        ]
      },
      'GFX' => {
        'file' => {
          'to' => 'lib/SDL/GFX.xs',
          'from' => 'src/GFX/GFX.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_primitives'
        ]
      },
      'SurfaceX' => {
        'file' => {
          'to' => 'lib/SDLx/Surface.xs',
          'from' => 'src/SDLx/Surface.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_gfx_primitives'
        ]
      },
      'VideoInfo' => {
        'file' => {
          'to' => 'lib/SDL/VideoInfo.xs',
          'from' => 'src/Core/objects/VideoInfo.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'AudioSpec' => {
        'file' => {
          'to' => 'lib/SDL/AudioSpec.xs',
          'from' => 'src/Core/objects/AudioSpec.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'LayerManagerX' => {
        'file' => {
          'to' => 'lib/SDLx/LayerManager.xs',
          'from' => 'src/SDLx/LayerManager.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'MixChunk' => {
        'file' => {
          'to' => 'lib/SDL/Mixer/MixChunk.xs',
          'from' => 'src/Mixer/objects/MixChunk.xs'
        },
        'libraries' => [
          'SDL',
          'SDL_mixer'
        ]
      },
      'AudioCVT' => {
        'file' => {
          'to' => 'lib/SDL/AudioCVT.xs',
          'from' => 'src/Core/objects/AudioCVT.xs'
        },
        'libraries' => [
          'SDL'
        ]
      },
      'Audio' => {
        'file' => {
          'to' => 'lib/SDL/Audio.xs',
          'from' => 'src/Core/Audio.xs'
        },
        'libraries' => [
          'SDL'
        ]
      }
    },
    'SDL_cfg' => {
      'MixerEffects' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Surface' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Video' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'ImageFilter' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_IMAGEFILTER'
        ],
        'libs' => {
          'SDL_gfx_imagefilter' => 1,
          'SDL' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'SFont' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_IMAGE'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_image' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_image'
        ]
      },
      'MixerSamples' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'TTF_Font' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_TTF'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_ttf' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_ttf'
        ]
      },
      'CD' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'TTF' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_TTF'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_ttf' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_ttf'
        ]
      },
      'ValidateX' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'FPSManager' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_FRAMERATE'
        ],
        'libs' => {
          'SDL_gfx_framerate' => 1,
          'SDL' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'MixerGroups' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Cursor' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'BlitFunc' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_BLITFUNC'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_gfx_blitfunc' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'Mixer' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Version' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'RWOps' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Primitives' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_PRIMITIVES'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_gfx_primitives' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'Events' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'PixelFormat' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Rotozoom' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_ROTOZOOM'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_gfx_rotozoom' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'Framerate' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_FRAMERATE'
        ],
        'libs' => {
          'SDL_gfx_framerate' => 1,
          'SDL' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'Rect' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Time' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'LayerX' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_IMAGE'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_image' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_image'
        ]
      },
      'StateX' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'CDROM' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Color' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'InterfaceX' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'CDTrack' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'MultiThread' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Mouse' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'TimerX' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'MixerChannels' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Joystick' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'MixMusic' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Palette' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Pango' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_PANGO'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_Pango' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_Pango'
        ]
      },
      'MixerMusic' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'Event' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'SDL' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Image' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_IMAGE'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_image' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_image'
        ]
      },
      'Context' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_PANGO'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_Pango' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_Pango'
        ]
      },
      'Overlay' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'GFX' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_PRIMITIVES'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_gfx_primitives' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'SurfaceX' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_GFX_PRIMITIVES'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_gfx_primitives' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_gfx'
        ]
      },
      'VideoInfo' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'AudioSpec' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'MixChunk' => {
        'defines' => [
          '-DHAVE_SDL',
          '-DHAVE_SDL_MIXER'
        ],
        'libs' => {
          'SDL' => 1,
          'SDL_mixer' => 1
        },
        'links' => [
          '-lSDL',
          '-lSDL_mixer'
        ]
      },
      'LayerManagerX' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'Audio' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      },
      'AudioCVT' => {
        'defines' => [
          '-DHAVE_SDL'
        ],
        'libs' => {
          'SDL' => 1
        },
        'links' => [
          '-lSDL'
        ]
      }
    },
    'libraries' => {
      'SDL_gfx_framerate' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX_FRAMERATE',
        'header' => 'SDL_framerate.h'
      },
      'GL' => {
        'lib' => 'opengl32',
        'define' => 'HAVE_GL',
        'header' => [
          'GL/gl.h',
          'GL/glext.h'
        ]
      },
      'SDL_gfx_imagefilter' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX_IMAGEFILTER',
        'header' => 'SDL_imageFilter.h'
      },
      'tiff' => {
        'lib' => 'tiff',
        'define' => 'HAVE_TIFF',
        'header' => 'tiff.h'
      },
      'SDL_ttf' => {
        'lib' => 'SDL_ttf',
        'define' => 'HAVE_SDL_TTF',
        'header' => 'SDL_ttf.h'
      },
      'SDL_Pango' => {
        'lib' => 'SDL_Pango',
        'define' => 'HAVE_SDL_PANGO',
        'header' => 'SDL_Pango.h'
      },
      'SDL_gfx_rotozoom' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX_ROTOZOOM',
        'header' => 'SDL_rotozoom.h'
      },
      'SDL_gfx_primitives' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX_PRIMITIVES',
        'header' => 'SDL_gfxPrimitives.h'
      },
      'png' => {
        'lib' => 'png',
        'define' => 'HAVE_PNG',
        'header' => 'png.h'
      },
      'SDL' => {
        'lib' => 'SDL',
        'define' => 'HAVE_SDL',
        'header' => 'SDL.h'
      },
      'GLU' => {
        'lib' => 'glu32',
        'define' => 'HAVE_GLU',
        'header' => 'GL/glu.h'
      },
      'SDL_image' => {
        'lib' => 'SDL_image',
        'define' => 'HAVE_SDL_IMAGE',
        'header' => 'SDL_image.h'
      },
      'SDL_gfx' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX',
        'header' => 'SDL_gfxPrimitives.h'
      },
      'jpeg' => {
        'lib' => 'jpeg',
        'define' => 'HAVE_JPEG',
        'header' => 'jpeglib.h'
      },
      'SDL_gfx_blitfunc' => {
        'lib' => 'SDL_gfx',
        'define' => 'HAVE_SDL_GFX_BLITFUNC',
        'header' => 'SDL_gfxBlitFunc.h'
      },
      'smpeg' => {
        'lib' => 'smpeg',
        'define' => 'HAVE_SMPEG',
        'header' => 'smpeg/smpeg.h'
      },
      'SDL_mixer' => {
        'lib' => 'SDL_mixer',
        'define' => 'HAVE_SDL_MIXER',
        'header' => 'SDL_mixer.h'
      }
    },
    'SDL_lib_translate' => {
      'SDL::Mixer::Effects' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::PixelFormat' => [
        'SDL'
      ],
      'SDL::Mouse' => [
        'SDL'
      ],
      'SDLx::Surface' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::Event' => [
        'SDL'
      ],
      'SDL::GFX::Primitives' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::CD' => [
        'SDL'
      ],
      'SDL::Video' => [
        'SDL'
      ],
      'SDL::Overlay' => [
        'SDL'
      ],
      'SDL::Surface' => [
        'SDL'
      ],
      'SDL::TTF' => [
        'SDL',
        'SDL_ttf'
      ],
      'SDL::Palette' => [
        'SDL'
      ],
      'SDL::Pango::Context' => [
        'SDL',
        'SDL_Pango'
      ],
      'SDLx::Controller::Timer' => [
        'SDL'
      ],
      'SDL_perl' => [
        'SDL'
      ],
      'SDL::Mixer::Groups' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::Mixer::Music' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::GFX::Rotozoom' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::Mixer::MixChunk' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::Mixer' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::Audio' => [
        'SDL'
      ],
      'SDL::Pango' => [
        'SDL',
        'SDL_Pango'
      ],
      'SDL::Mixer::MixMusic' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::AudioSpec' => [
        'SDL'
      ],
      'SDL::Color' => [
        'SDL'
      ],
      'SDL::VideoInfo' => [
        'SDL'
      ],
      'SDLx::SFont' => [
        'SDL',
        'SDL_image'
      ],
      'SDL::Mixer::Samples' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::GFX::Framerate' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::GFX::FPSManager' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::MultiThread' => [
        'SDL'
      ],
      'SDL::Image' => [
        'SDL',
        'SDL_image'
      ],
      'SDL::AudioCVT' => [
        'SDL'
      ],
      'SDL::Rect' => [
        'SDL'
      ],
      'SDL::GFX::BlitFunc' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDLx::Validate' => [
        'SDL'
      ],
      'SDLx::LayerManager' => [
        'SDL'
      ],
      'SDL::Version' => [
        'SDL'
      ],
      'SDL::CDROM' => [
        'SDL'
      ],
      'SDL::Time' => [
        'SDL'
      ],
      'SDLx::Controller::State' => [
        'SDL'
      ],
      'SDL::Mixer::Channels' => [
        'SDL',
        'SDL_mixer'
      ],
      'SDL::GFX' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::GFX::ImageFilter' => [
        'SDL',
        'SDL_gfx'
      ],
      'SDL::Events' => [
        'SDL'
      ],
      'SDLx::Layer' => [
        'SDL',
        'SDL_image'
      ],
      'SDL::Joystick' => [
        'SDL'
      ],
      'SDL::TTF::Font' => [
        'SDL',
        'SDL_ttf'
      ],
      'SDL::CDTrack' => [
        'SDL'
      ],
      'SDL::RWOps' => [
        'SDL'
      ],
      'SDL::Cursor' => [
        'SDL'
      ],
      'SDLx::Controller::Interface' => [
        'SDL'
      ]
    }
  },
  {},
  {}
];
$x; }