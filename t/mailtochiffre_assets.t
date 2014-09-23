#!/usr/bin/env perl
package TestApp;
use Mojo::Base 'Mojolicious';
use Test::More;

sub startup {
  my $app = shift;
  $app->plugin('Config' => { file => $app->home . '/mailtochiffre.conf' });
  $app->plugin('AssetPack');
  $app->plugin('TagHelpers::MailToChiffre');
  $app->routes->get('/contact')->mail_to_chiffre(
    cb => sub {
      shift->render(text => 'hey');
    }
  );

  is($app->mail_to_chiffre->styles, '/contact/style.css', 'Styles');
  is($app->mail_to_chiffre->scripts, '/contact/script.js', 'Scripts');

  $app->asset(
    'my.js' => $app->mail_to_chiffre->scripts
  );
};

package main;
use Test::More;
use Test::Mojo;

use strict;
use warnings;

my $t = Test::Mojo->new;

$t->app(TestApp->new);

is($t->app->url_for('mailToChiffreCSS'), '/contact/style.css', 'CSS Asset');

$t->get_ok('/contact/style.css')
  ->status_is(200)
  ->content_is(q!a[onclick$='return obf(this,false)']{direction:rtl;unicode-bidi:bidi-override}a[onclick$='return obf(this,false)']>span:nth-child(1n+2){display:none}a[onclick$='return obf(this,false)']>span:nth-child(1):after{content:'@'}!);

$t->get_ok('/contact/script.js')
  ->status_is(200)
  ->content_like(qr/^function obf/);

done_testing;
