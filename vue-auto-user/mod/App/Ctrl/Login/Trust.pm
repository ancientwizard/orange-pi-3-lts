##
##  App::Ctrl::Login::Trust
##

package App::Ctrl::Login::Trust;

use strict;
use warnings;
use Carp;
use File::Temp qw/ tempfile tempdir /;

our $VERSION = 0.1;

my $TYPE    = 0;
my $PUBLIC  = 1;
my $NOTE    = 3;
my $CHECK   = 4;

## AKA: acceptable types
my $EXPECTED_TYPES = {
      'ssh-ed25519'         => 1,
      'ecdsa-sha2-nistp256' => 1,
      'ecdsa-sha2-nistp384' => 1,
      'ecdsa-sha2-nistp521' => 1,
      'ssh-rsa'             => 1
 };

sub new
{
  my $class = ref $_[0] ? ref shift : shift;

  return bless [], $class;
}

sub load
{
  my $self = shift;
  my $full = shift;

  if ( $full )
  {
    ( $self->[ $TYPE ], $self->[ $PUBLIC ], $self->[ $NOTE ] )
      = ( split ' ', $full, 3 );
  }

  return $self;
}

sub validate
{
  my $self    = shift;
  my $keytype = $self->keytype;
  my $public  = $self->public;

  croak sprintf '400 Invalid OR Unaceptable key [%s]', $public
    unless $keytype && $public && exists( $EXPECTED_TYPES->{ $keytype } )
        && $public =~ m{^[a-zA-Z0-9+/=]+$}ix;

  ## Must pass ssh-keygen sniff test!
  my $tempdir = tempdir( CLEANUP => 1 );
  my ( $fh, $filename ) = tempfile( DIR => $tempdir );

  printf $fh "from=\"127.0.0.1\" %s %s no note\n", $keytype, $public;
  close $fh;

  # system( '/bin/cat', $filename );
  # system( '/usr/bin/ssh-keygen', '-l', '-f', $filename );
  # printf "# DIR = %s\n", $tempdir;
  # printf "# FIL = %s\n", $filename;

  my $cmd    = '/usr/bin/ssh-keygen -l -f ' . $filename; # . '-2.pub';
  my $output = qx=$cmd=;
  my $status = $? >> 8;

  ## Clean up
  $filename = $fh = $tempdir = '';

  chomp $output  if $output;
  $self->[ $CHECK ] = $output;
  # print STDERR '# ->> ' . $output . "\n";

  croak '400 Invalid OR Unaceptable key (ssh-keygen inspected)'
    if $status;

  return $self;
}

sub keytype   { return $_[0]->[ $TYPE   ] // '' }
sub public    { return $_[0]->[ $PUBLIC ] // '' }
sub note      { return $_[0]->[ $NOTE   ] // '' }
sub checkmsg  { return $_[0]->[ $CHECK  ] // '' }

## END
