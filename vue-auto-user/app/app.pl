
#  USAGE: hypnotoad app.pl
#
# This API provides the back-end actions to implement the vue-auto-user application
#

use Mojolicious::Lite -signatures;
use IPC::Open3;
use Carp;
use Symbol 'gensym';
use lib '../mod/';
use App::Ctrl::Login::Trust;
use App::Ctrl::Login::User;

under '/api/v1/';

get '/Ping' => sub ($c)
{
  $c->render( json => { code => 200, message => 'PING-ACK' } );
};

get '/' => sub ($c)
{
  $c->render( json => { code => 200, message => 'success' } );
};

get '/user/status/' => sub ($c)
{
  my $uname = lc( $c->param('username') // '' );
  my $user  = App::Ctrl::Login::User->new->load( $uname );

  eval
  {
    ## Throws exceptions
    $user->validate;

    $c->render( json => { code => 200, message => 'success', username => $user->uname
      , uid => $user->uid, gid => $user->gid, home => $user->home, shell => $user->shell } );
  }
  or do
  {
    my ( $code, $mesg ) = exception_2_code( $@ );
    $c->render( json => { code => $code, message => $mesg, username => $uname } );
  };
};

get '/user/keycheck/' => sub ($c)
{
  my $public = $c->param('public');
  my $key    = App::Ctrl::Login::Trust->new->load( $public );

  eval
  {
    ## Throws exceptions
    $key->validate;

    $c->render( json => { code => 200, message => 'Key Check Success'
      , public => $public, checkmsg => $key->checkmsg } );
  }
  or do
  {
    my ( $code, $mesg ) = exception_2_code( $@ );
    $c->render( json => { code => $code, message => $mesg
      , public => $public, checkmsg => $key->checkmsg } );
  };
};

get '/user/add/' => sub ($c)
{
  my $uname  = $c->param('username');
  my $public = $c->param('public');

  my $user   = App::Ctrl::Login::User->new->load( $uname );
  my $key    = App::Ctrl::Login::Trust->new->load( $public );

  eval
  {
    ## Validate inputs Throws exceptions
    $key->validate;
    $user->validate( throw_on_found => 1 );

    # $c->render( json => { code => 200, message => 'Add User', username => $uname } );

    my ( $err, $in, $out, $pid ) = ( gensym );
    my ( $tout, $eout, $status ) = ( [], [] );
    my ( $code, $mesg );

    if ( $pid = IPC::Open3::open3( $in, $out, $err, '/usr/bin/sudo', '/var/www/orange-pi-3-lts/vue-auto-user/bin/user-add', $uname ))
    {
      printf $in "from=\"%s\" %s %s empty-comment\n", $c->tx->original_remote_address
        , $key->keytype, $key->public;
      close( $in ) or 1;
      waitpid( $pid, 0 );
      $status = $? >> 8;
      $tout = [ <$out> ];
      $eout = [ <$err> ];
      chomp( @$tout );
      chomp( @$eout );
      $code = $status ? 400 : 200;
      $mesg = $status ? 'failed' : 'success';
      $user = App::Ctrl::Login::User->new->load( $uname );
    }
    else
    {
      croak sprintf '400 %s', $!;
    }

    $c->render( json => { code => $code, message => $mesg, username => $uname
        , uid => $user->uid, gid => $user->gid, home => $user->home, shell => $user->shell
        , err => $eout , out => $tout } );
  }
  or do
  {
    my ( $code, $mesg ) = exception_2_code( $@ );
    $c->render( json => { code => $code, message => $mesg
      , public => $public, checkmsg => $key->checkmsg } );
  };
};

app->config(
  ## options specific to hypnotoad
  hypnotoad => {
#   listen  => [ 'http://localhost:5080' ],
    listen  => [ 'http://*:5080' ],
    proxy   => 1
  }
);

app->start;


## Helpers

sub exception_2_code
{
  my $msg = shift;
  my ( $code, $mesg ) = split ' ', $msg, 2;

  $mesg = ( split ' at ', $mesg, 2 )[0];

  return $code, $mesg;
}

# vim: ts=2 expandtabs
#  vi: ts=2 expandtabs
# END
