.PHONY: bootstrap test lint build-backend build-mobile run-infra stop-infra clean dev-mobile

bootstrap:
	cd apps/mobile && flutter pub get

test:
	cd apps/mobile && flutter test

lint:
	cd apps/mobile && flutter analyze

build-backend:
	cd backend/acadyk-api && ./gradlew build -x test

build-mobile:
	cd apps/mobile && flutter build apk

run-infra:
	docker-compose up -d postgres redis kafka elasticsearch

run-all:
	docker-compose up -d

stop-infra:
	docker-compose down

dev-mobile:
	cd apps/mobile && flutter run -d chrome

clean:
	cd apps/mobile && flutter clean
