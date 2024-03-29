#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open ':utf8';
use open ':std';
use URI;
use Web::Scraper;
use LWP::UserAgent;

# FIXED:
# SSL connect attempt failed error:0A000152:SSL routines::unsafe legacy renegotiation disabled

my $ua = LWP::UserAgent->new(
  ssl_opts => {
    verify_hostname => 0,
    SSL_create_ctx_callback => sub {
      my $ctx = shift;
      # 0x00040000 SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION
      Net::SSLeay::CTX_set_options($ctx, 0x40000);
      Net::SSLeay::CTX_set_security_level($ctx, 1);
    },
  }
);

my $items = scraper {
  process 'table tr', 'items[]' => scraper {
    process 'td:nth-child(1)', 'name' => 'HTML';
    process 'td:nth-child(4)', 'alt' => 'TEXT';
    process 'td:nth-child(5)', 'pos' => 'TEXT';
    process 'td:nth-child(7)', 'note' => 'TEXT';
  };
};
$items->user_agent($ua);

my %gaiji = (
  'やくらいさん' => '薬萊山',
  'びょうぶだけ' => '屛風岳',
  'えぶりさしだけ' => '朳差岳',
  'しばやすぐら' => '柴安嵓',
  'びょうぶざん' => '屛風山'
);

my $res = $items->scrape(URI->new('https://www.gsi.go.jp/kihonjohochousa/kihonjohochousa41140.html'));
my $id = 0;
for my $item (@{$res->{items}}) {
  my $s = $item->{name};
  next if (!$s);
  ++$id;
  if ($s =~ /<img/) {
    $s =~ s%<img alt="([^"]*)"[^>]*>%$gaiji{$1}%;
  }
  $s =~ m%^([^<]*)<br */><a [^>]*>([^<]*)</a>$% or die;
  my $kana = $1;
  my $name = $2;
  $kana =~ s/&lt;/＜/g;
  $kana =~ s/&gt;/＞/g;
  $kana =~ y/()/（）/;
  $name =~ s/&lt;/＜/g;
  $name =~ s/&gt;/＞/g;
  $name =~ y/()/（）/;
# 総称
  my $name0 = '';
  my $kana0 = '';
  if ($name =~ /^(.*)＜(.*)＞$/) {
    $name0 = $1;
    $name = $2;
    $kana =~ /^(.*)＜(.*)＞$/ or die;
    $kana0 = $1;
    $kana = $2;
  }
# 別名
  my $name2 = '';
  my $kana2 = '';
  if ($name =~ /^(.*)（(.*)）$/) {
    $name = $1;
    $name2 = $2;
    if ($kana =~ /^(.*)（(.*)）$/) {
      $kana = $1;
      $kana2 = $2;
    } else {
      $kana2 = $kana;
    }
  }
# 細かな修正
  $name =~ s/ //g;
  $kana =~ s/ //g;
  $name =~ s/^\[(.*)\]$/$1/;
  $kana =~ s/^\[(.*)\]$/$1/;
  $name0 =~ s/^\[(.*)\]$/$1/;
  $kana0 =~ s/^\[(.*)\]$/$1/;

  $item->{alt} =~ m%^(\d+)m$% or die;
  my $alt = $1;
  $item->{pos} =~ m%^(\d+)度(\d+)分(\d+)秒\s*(\d+)度(\d+)分(\d+)秒$% or die;
  my $lat = $1 . $2 . $3;
  my $lon = $4 . $5 . $6;
  my $note = '"' . $item->{note} . '"';
  print join(',', ($id, $kana0, $name0, $kana, $name, $kana2, $name2, $alt, $lat, $lon, $note)), "\n";
}
__END__
