all: css/omap_geojson.css css/omap_pbf.css

css/%.css: src/%.css
	@cleancss -o $@ $^
	@echo $@
