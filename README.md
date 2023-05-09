# map-jpn-org
Mountains in Japan on the web map - components and method of construction

## はじめに
多数（1000以上）のPOI（point of interest）データを記述したGeoJSONファイルを用いて、Web地図上にPOIを表示するHTML+CSS+JavaScriptのサンプルコードを示す。地図ライブラリとして、[Leaflet](https://leafletjs.com/)、[OpenLayers](https://openlayers.org/)、[Google Maps API](https://developers.google.com/maps/documentation/javascript/?hl=ja)、[Bing Maps API](https://docs.microsoft.com/en-us/bingmaps/v8-web-control/)、[Mapbox GL JS](https://docs.mapbox.com/mapbox-gl-js/)を用いる。さらに、GeoJSONファイルからMVT形式のベクトルタイル（拡張子 .pbf）を作成し、これを用いてPOIを表示するサンプルコードも示す（現状ではOpenLayers、Mapbox GL JSのみ）。

POIの例として、国土地理院のサイトで公開されている[日本の主な山岳一覧](https://www.gsi.go.jp/kihonjohochousa/kihonjohochousa41140.html)のデータ（山名、よみ、標高、緯度経度）を用いる。このウェブページから必要な情報を抽出してCSVファイルで保存するスクレイパースクリプト（get_mt.pl）、CSV→GeoJSONファイル変換スクリプト（csv2geojson.pl）も公開する。GeoJSONからMVTファイルを作成する方法についても説明する。

## 表示例
いずれのサンプルコードも、`mt.geojson`を読み込み、地図画像を背景として、山の位置にアイコンと山名を表示する。アイコンをクリックすると、山名に加えてよみがなや緯度、経度、標高、ID（山名データの通し番号）をポップアップで表示する。いくつかのサンプルコードでは、山名が密集して表示が重なる場合に間引き表示（decluttering）を行う。最新版のChrome、Firefix、Safari、Microsoft Edgeおよび（Mapbox GL JSを除いて）IE11で表示できる。

なお、Leafletの表示例はGeoJSONファイルの読み込みに時間がかかる。Google Maps APIでは山の位置に山名が表示されないが、アイコンにマウスカーソルを当てるとツールチップで山名が表示される。

|JSライブラリ|表示例|
|:---|:---|
|Leaflet|[lmap_geojson.html](https://anineco.nyanta.jp/map-jpn-org/lmap_geojson.html)|
|OpenLayers|[omap_geojson.html](https://anineco.nyanta.jp/map-jpn-org/omap_geojson.html)|
|Google Maps API|[gmap_geojson.html](https://anineco.nyanta.jp/map-jpn-org/gmap_geojson.html)|
|Bing Maps API|[bmap_geojson.html](https://anineco.nyanta.jp/map-jpn-org/bmap_geojson.html)|
|Mapbox GL JS|[mmap_geojson.html](https://anineco.nyanta.jp/map-jpn-org/mmap_geojson.html)|

注意：Google Maps API、Bing Maps API、Mapbox GL JSのサンプルコードを用いる場合は、HTMLファイル中の'\_YOUR_API_KEY\_'を各自で取得したAPI KEYに書き換える必要がある。

次のサンプルコードは、`mt.geojson`を変換して作成したMVTファイル（`https://anineco.nyanta.jp/map-jpn-org/mt/{z}/{x}/{y}.pbf`）を読み込んで、同様の表示を行う。

|JSライブラリ|表示例|
|:---|:---|
|OpenLayers|[omap_pbf.html](https://anineco.nyanta.jp/map-jpn-org/omap_pbf.html)|
|Mapbox GL JS|[mmap_pbf.html](https://anineco.nyanta.jp/map-jpn-org/mmap_pbf.html)|

なお、GeoJSONファイル読み込みをMVTファイル読み込みに変更するための差分は以下の通り。どちらもごく一部の変更だけで済む。

- OpenLayers
```
182,185c182,185
<       const sanmei = new ol.layer.Vector({
<         source: new ol.source.Vector({
<           url: 'mt.geojson',
<           format: new ol.format.GeoJSON()
---
>       const sanmei = new ol.layer.VectorTile({
>         source: new ol.source.VectorTile({
>           url: 'mt/{z}/{x}/{y}.pbf',
>           format: new ol.format.MVT()
206c206
<         const lonlat = ol.proj.toLonLat(feature.getGeometry().getCoordinates());
---
>         const lonlat = ol.proj.toLonLat(feature.getFlatCoordinates());
228c228
<             coordinate = geometry.getCoordinates();
---
>             coordinate = feature.getFlatCoordinates();
```

- Mapbox GL JS
```
73,74c73,75
<           'type': 'geojson',
<           'data': 'mt.geojson'
---
>           'type': 'vector',
>           'tiles': [ 'https://anineco.nyanta.jp/map-jpn-org/mt/{z}/{x}/{y}.pbf' ],
>           'maxzoom': 14
78a80
>           'source-layer': 'mt',
```

## データファイルの作成方法
GeoJSONファイルからMVTファイルの変換には、[tippecanoe](https://github.com/mapbox/tippecanoe)を用いる。MVTファイルは`mt`フォルダの中に配置される。
```
./get_mt.pl > mt.csv
./csv2geojson.pl < mt.csv > mt.geojson
tippecanoe -Z8 -r1 --no-tile-compression -e mt mt.geojson
```
