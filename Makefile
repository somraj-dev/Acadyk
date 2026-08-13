.PHONY: bootstrap test lint build-android clean

bootstrap:
	./scripts/bootstrap.sh

test:
	./scripts/test.sh

lint:
	./scripts/lint.sh

build-android:
	./scripts/release.sh

clean:
	cd apps/mobile && flutter clean
