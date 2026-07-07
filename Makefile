.PHONY: test
test:
	swift test

.PHONY: sprites
sprites:
	python3 tools/generate_sprites.py
