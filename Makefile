.PHONY: bootstrap test lint build-android clean web chrome dev

bootstrap:
	./scripts/bootstrap.sh

test:
	./scripts/test.sh

lint:
	./scripts/lint.sh

web:
	cd apps/mobile && flutter run -d web-server --web-port 8080 --web-hostname localhost

chrome:
	cd apps/mobile && flutter run -d chrome

dev: web

build-android:
	./scripts/release.sh

clean:
	cd apps/mobile && flutter clean

