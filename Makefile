.PHONY: dev build clean

dev:
	hugo server --buildDrafts --disableFastRender

build:
	hugo --environment production

clean:
	rm -rf public/ resources/ .hugo_build.lock
