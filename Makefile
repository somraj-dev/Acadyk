.PHONY: bootstrap test lint build-backend build-mobile build-android run-infra run-all stop-infra clean dev dev-mobile web chrome

bootstrap:
	cd apps/mobile && flutter pub get

test:
	cd apps/mobile && flutter test

lint:
	cd apps/mobile && flutter analyze

web:
	cd apps/mobile && flutter run -d web-server --web-port 8080 --web-hostname localhost

chrome:
	cd apps/mobile && flutter run -d chrome

dev: web

dev-mobile:
	cd apps/mobile && flutter run -d chrome

build-backend:
	cd backend/acadyk-api && ./gradlew build -x test

build-mobile:
	cd apps/mobile && flutter build apk

build-android:
	./scripts/release.sh

run-infra:
	docker-compose up -d postgres redis kafka

run-all:
	docker-compose up -d

stop-infra:
	docker-compose down

clean:
	cd apps/mobile && flutter clean
