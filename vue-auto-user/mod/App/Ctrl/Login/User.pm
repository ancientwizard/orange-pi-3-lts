##
##  App::Ctrl::Login::Use
##

package App::Ctrl::Login::User;

use strict;
use warnings;
use Carp;

our $VERSION = 0.1;

my $UNAME = 0;
my $UID   = 1;
my $GID   = 2;
my $HOME  = 3;
my $SHELL = 4;

sub new
{
  my $class = ref $_[0] ? ref shift : shift;

  return bless [], $class;
}

sub load
{
  my $self  = shift;
  my $uname = shift;

  $self->[ $UNAME ] = $uname || '-- undefined --';

  if ( $uname )
  {
     ( $self->[ $UID ], $self->[ $GID ], $self->[ $HOME ], $self->[ $SHELL ] )
       = ( getpwnam $uname )[2,3,7,8];
  }

  return $self;
}

sub validate
{
  my $self  = shift;
  my $check = ref $_[0] ? shift : { @_ };
  my $uname = $self->[ $UNAME ];
  my $uid   = $self->[ $UID ];

  croak sprintf '400 Invalid Username [ %s ]', $uname
    unless $uname && length( $uname ) <= 24 && $uname =~ m=^[a-z][a-z0-9]+$=ix;

  croak sprintf '404 Not Found [ %s ]', $uname
    unless $check->{ throw_on_found } or defined $uid;

  croak sprintf '404 Uname Found [ %s ]', $uname
    if $check->{ throw_on_found } && defined $uid;

  croak sprintf '400 Reserved [ %s ]', $uname
    unless ! defined $uid || $uid >= 2000;

  return $self;
}

sub uname { return $_[0]->[ $UNAME ] }
sub uid   { return $_[0]->[ $UID   ] }
sub gid   { return $_[0]->[ $GID   ] }
sub home  { return $_[0]->[ $HOME  ] }
sub shell { return $_[0]->[ $SHELL ] }


## END
