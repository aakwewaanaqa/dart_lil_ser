.ONESHELL:

prebuild:
	@echo "Building..."
	@rm -rf lib/*/*.g.dart
	@dart run build_runner build

export: prebuild
	@echo "Exporting..."
	@mkdir -p build
	@./to_builds.sh

run:
	@echo "Running..."
	@dart run bin/main.dart file