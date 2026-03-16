.PHONY: dev build clean

dev:
	hugo server --buildDrafts

build:
	hugo && npx -y pagefind --site public

clean:
	rm -rf public
