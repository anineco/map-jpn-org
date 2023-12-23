#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open ':utf8';
use open ':std';

# 総称は
# 1. 最高峰のみに付す
# 2. 最高峰以外に総称と同じ山頂名がないこと
#    397 愛鷹山(1187m)がある
#    841 比婆山(1264m)がある
#    892 象頭山(538m)がある
my @sosho = (
  35, 110, 117, 156, 159, 173, 185, 187, 188, 212,
  237, 265, 268, 279, 283, 294, 305, 315, 334, 338,
  340, 343, 377, 396, 400, 404, 407, 440, 442, 502,
  546, 549, 615, 623, 674, 683, 722, 734, 753, 774,
  830, 832, 846, 884, 929, 967, 973, 991, 994, 1020,
  1023
);

sub dms2deg {
  my $dms = shift;
  $dms =~ /^(\d+)(\d\d)(\d\d)$/;
  return sprintf "%.6f", ($3 / 60 + $2) / 60 + $1;
}

my $comment = <<'EOS';
CREATE TABLE `geom` (
  `id` smallint unsigned NOT NULL COMMENT 'ID',
  `kana` varchar(255) NOT NULL COMMENT 'よみ',
  `name` varchar(255) NOT NULL COMMENT '山名',
  `pt` point NOT NULL /*!80003 SRID 4326 */ COMMENT '位置',
  `lat` double GENERATED ALWAYS AS (round(st_y(`pt`),6)) VIRTUAL NOT NULL COMMENT '緯度',
  `lon` double GENERATED ALWAYS AS (round(st_x(`pt`),6)) VIRTUAL NOT NULL COMMENT '経度',
  `alt` smallint NOT NULL COMMENT '標高[m]',
  PRIMARY KEY (`id`),
  SPATIAL KEY `pt` (`pt`)
);
/*!80003
ALTER TABLE `geom` MODIFY COLUMN `lat` double GENERATED ALWAYS AS (round(st_x(`pt`),6)) VIRTUAL NOT NULL COMMENT '緯度';
ALTER TABLE `geom` MODIFY COLUMN `lon` double GENERATED ALWAYS AS (round(st_y(`pt`),6)) VIRTUAL NOT NULL COMMENT '緯度';
*/
EOS

print $comment, "\n";

print 'INSERT INTO `geom` VALUES', "\n";
my $count = 0;
while (<>) {
  chomp;
  my ($id, $kana0, $name0, $kana, $name, $kana2, $name2, $alt, $lat, $lon, $note) = split(/,/);
  $name =~ y/０-９/0-9/;
  if ($kana0 =~ /^(.*)（.*）$/) {
    $kana0 = $1;
  }
  if ($name0 && grep { $_ == $id } @sosho) {
    $name = $name0 . '・' . $name;
    $kana = $kana0 . '・' . $kana;
  }
  $lat = dms2deg($lat);
  $lon = dms2deg($lon);
  if ($count > 0) {
    print ',', "\n";
  }
  print qq{($id,"$kana","$name",ST_GeomFromText('POINT($lon $lat)',4326/*!80003 ,'axis-order=long-lat'*/),$alt)};
  $count++;
}
print ";\n";
__END__
