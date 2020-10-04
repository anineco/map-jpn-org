# map-jpn-org
Mountains in Japan on the web map - components and method of construction

## はじめに
多数（1000以上）のPOI（point of interest）のデータを記述したGeoJSONファイルを用いて、Web地図上にPOIを表示するHTML+CSS+JavaScriptコードの例を示す。地図ライブラリとして、Leaflet、OpenLayers、Google Maps、Bing Maps、Mapbox GL JSを用いる。さらに、GeoJSONファイルからMVT（PBF）形式のベクトルタイルを作成し、これを用いてPOIを表示するコード例も示す（現状はOpenLayers、Mapbox GL JSのみ）。

POIの例として、国土地理院のサイトで公開されている[日本の主な山岳一覧](https://www.gsi.go.jp/kihonjohochousa/kihonjohochousa41140.html)のデータ（山名、よみ、標高、緯度経度）を用いる。このウェブページから情報を抽出するスクレイパー・スクリプトと、GeoJSONファイル、MVTファイルの作成方法についても説明する。

## 表示例
いずれも、'mt.geojson'を読み込み、地図画像を背景として、山の位置にアイコンと山名を表示する。アイコンをクリックすると、山名に加えてよみがなや緯度、経度、標高をポップアップで表示する。いくつかの例では、山名が密集して表示が重なる場合に間引き表示（decluttering）を行う。最新版のChrome、Edge、Firefix、SafariおよびIE11で表示できる。

| JSライブラリ | 表示例 |
| ------------- | ------------- |
| Leaflet | https://anineco.nyanta.jp/map-jpn-org/lmap_geojson.html |
| OpenLayers | https://anineco.nyanta.jp/map-jpn-org/omap_geojson.html |
| Google Maps | https://anineco.nyanta.jp/map-jpn-org/gmap_geojson.html |
| Bing Maps | https://anineco.nyanta.jp/map-jpn-org/bmap_geojson.html |
| Mapbox GL JS | https://anineco.nyanta.jp/map-jpn-org/mmap_geojson.html |

なお、Google Maps、Bing Mapsのコード例を用いる場合は、HTMLファイル中の'_YOUR_API_KEY_'を各自で取得したAPI KEYに書き換える必要がある。

次の例は、'mt.geojson'を変換して作成したMVTファイルを読み込んで、同様の表示を行う。

| JSライブラリ | 表示例 |
| ------------- | ------------- |
| OpenLayers | https://anineco.nyanta.jp/map-jpn-org/omap_pbf.html |
| Mapbox GL JS | https://anineco.nyanta.jp/map-jpn-org/mmap_pbf.html |

## データファイルの作成方法
GeoJSONファイルからMVTファイルの変換には、[tippecanoe](https://github.com/mapbox/tippecanoe)を用いる。
```
./get_mt.pl > mt.csv
./csv2geojson.pl < mt.csv > mt.geojson
tippecanoe -Z8 -r1 --no-tile-compression -e mt mt.geojson
```
