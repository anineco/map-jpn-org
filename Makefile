all: css/omap.css

css/%.css: src/%.css
	@cleancss -o $@ $^
	@echo $@
