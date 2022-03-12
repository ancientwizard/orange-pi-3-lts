#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Carp;

use lib (dirname $0) . '/../mod/';
use Test::More;

use_ok 'App::Ctrl::Login::Trust';

local $Data::Dumper::Indent = 1;
local $Data::Dumper::Terse  = 1;

UNIT:
{
  note '+ -------------------------------------------------- +';
  note '  UNIT Testing';
  note '+ -------------------------------------------------- +';

  ok App::Ctrl::Login::Trust->new, '->new';
  note Dumper( App::Ctrl::Login::Trust->new );

  my $key = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKw/Jo5H5HLkykkm/ejciAJ0QHFY/wo1UjawZI6o+Deq root@orangepi3-lts';
 
  # Load
  is App::Ctrl::Login::Trust->new->load( $key )->keytype,         'ssh-ed25519', '->load->type';
  is App::Ctrl::Login::Trust->new->load( $key )->public, ( split ' ', $key )[1], '->load->public';
  is App::Ctrl::Login::Trust->new->load( $key )->note,     'root@orangepi3-lts', '->load->note';

  App::Ctrl::Login::Trust->new->load( $key )->validate;
}

done_testing();

## Helpers


## END
