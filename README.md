# map-jpn-org
Mountains in Japan on the web map - components and method of construction

## はじめに
多数（1000以上）のPOI（point of interest）のデータを記述したGeoJSONファイルを用いて、Web地図上にPOIを表示するHTML+CSS+JavaScriptコードの例を示す。地図ライブラリとして、Leaflet、OpenLayers、Google Maps、Bing Mapsを用い、機能や性能を比較する。さらに、GeoJSONファイルからMVT形式のベクトルタイルを作成し、これを用いてPOIを表示するコード例も示す（現状はOpenLayersのみ）。

POIの例として、国土地理院のサイトで公開されている[日本の主な山岳一覧](https://www.gsi.go.jp/kihonjohochousa/kihonjohochousa41140.html)のデータ（山名、よみ、標高、緯度経度）を用いる。このウェブページから情報を抽出するスクレイパー・スクリプトと、GeoJSONファイル、MVTファイルの作成方法についても説明する。

## 表示例
いずれも、地図画像を背景として、山の位置にアイコンと山名を表示し、アイコンをクリックすると、山名に加えてよみがなや緯度、経度、標高をポップアップで表示する。いくつかの例では、山名が密集して表示が重なる場合に間引き表示（decluttering）を行う。最新版のChrome、Edge、Firefix、SafariおよびIE11で表示できる。
- Leaflet 1.6.0
- https://anineco.nyanta.jp/map-jpn-org/lmap_geojson.html
- OpenLayers 6.4.3
- https://anineco.nyanta.jp/map-jpn-org/omap_geojson.html
- Google Maps
- https://anineco.nyanta.jp/map-jpn-org/omap_geojson.html
- Bing Maps
- https://anineco.nyanta.jp/map-jpn-org/bmap_geojson.html

