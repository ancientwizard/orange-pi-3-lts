#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Carp;

use lib (dirname $0) . '/../mod/';
use Test::More;

use_ok 'App::Ctrl::Login::User';

local $Data::Dumper::Indent = 1;
local $Data::Dumper::Terse  = 1;

UNIT:
{
  note '+ -------------------------------------------------- +';
  note '  UNIT Testing';
  note '+ -------------------------------------------------- +';

  ok App::Ctrl::Login::User->new, '->new';
  note Dumper( App::Ctrl::Login::User->new );

  # Load
  is App::Ctrl::Login::User->new->load( 'root' )->uname,      'root', '->load->uname';
  is App::Ctrl::Login::User->new->load( 'root' )->uid,             0, '->load->uid';
  is App::Ctrl::Login::User->new->load( 'root' )->gid,             0, '->load->gid';
  is App::Ctrl::Login::User->new->load( 'root' )->home,      '/root', '->load->home';
  is App::Ctrl::Login::User->new->load( 'root' )->shell, '/bin/bash', '->load->shell';

  # Resurved + Invald
  for my $uname ( get_unames() )
  {
    eval { App::Ctrl::Login::User->new->load( $uname )->validate; croak 'FAILED' }
    or do
    {
      $@ =~ m=Reserved=x
      ? like $@, qr=400\sReserved\s=xi, 'Detected as reserved -> ' . $uname
      : like $@, qr=400\sInvalid\sUsername\s=xi, 'Detected as Invalid Username -> ' . $uname;
    };
  }

  # Bad uname
  for my $uname ( '6number', 'thisistoolngbyfar892123456' )
  {
    eval { App::Ctrl::Login::User->new->load( $uname )->validate; croak 'FAILED'; }
    or do
    {
      like $@, qr=400\sInvalid\sUsername\s=xi, 'Detected as Invalid Username -> ' . $uname;
    };
  }

  # Not Found
  eval { App::Ctrl::Login::User->new->load( 'unexpected' )->validate; croak 'FAILED'; }
  or do
  {
    like $@, qr=404\sNot\sFound\s=xi, 'Detected as Not Found -> unexpected';
  };

  # Valid & Found
  eval {
    App::Ctrl::Login::User->new->load( 'victor' )->validate;
    ok 1, '(victor)->validate'; }
  or do
  {
    note $@
  };
}

done_testing();

## Helpers

sub get_unames
{
  my $limit  = 1000;
  my $unames = [];

  if ( open my $PW, '<', '/etc/passwd' )
  {
    while ( my $line = <$PW> )
    {
      my ( $uname, $uid ) = ( split ':', $line )[0,2];
      next unless $uid < $limit;
      push @ $unames, $uname;
    }
    close $PW;
  }

  return @$unames;
}

## END
