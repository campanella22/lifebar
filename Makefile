.PHONY: test
test:
	swift test

.PHONY: sprites
sprites:
	python3 tools/generate_sprites.py

APP = dist/LifeBar.app

.PHONY: app run clean
app:
	swift build -c release
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS $(APP)/Contents/Resources
	cp .build/release/LifeBar $(APP)/Contents/MacOS/
	cp -R .build/release/LifeBar_LifeBar.bundle $(APP)/Contents/Resources/
	cp tools/Info.plist $(APP)/Contents/
	# アイコン: icon_512.png から .icns を作る
	rm -rf dist/AppIcon.iconset
	mkdir -p dist/AppIcon.iconset
	sips -z 512 512 Sources/LifeBar/Resources/sprites/icon_512.png \
	  --out dist/AppIcon.iconset/icon_512x512.png >/dev/null
	sips -z 256 256 Sources/LifeBar/Resources/sprites/icon_512.png \
	  --out dist/AppIcon.iconset/icon_256x256.png >/dev/null
	sips -z 128 128 Sources/LifeBar/Resources/sprites/icon_512.png \
	  --out dist/AppIcon.iconset/icon_128x128.png >/dev/null
	iconutil -c icns dist/AppIcon.iconset -o $(APP)/Contents/Resources/AppIcon.icns
	codesign --force --deep -s - $(APP)
	@echo "→ $(APP)"

run: app
	open $(APP)

clean:
	rm -rf .build dist
