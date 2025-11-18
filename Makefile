.DEFAULT: flight-managerd
.PHONY: aarch64-unknown-linux-gnu x86_64-unknown-linux-gnu aarch64-apple-darwin help

ARCHITECTURES := aarch64-unknown-linux-gnu aarch64-apple-darwin x86_64-unknown-linux-gnu

OUT_PATH := bin
OUT_FILE_NAME := libdji_log_parser_c.a

$(ARCHITECTURES):
	docker build -f build/$@/Dockerfile -t dji-log-parser:$@ . 
	ID=$(shell docker create dji-log-parser:$@); \
	docker cp $$ID:/usr/src/myapp/target/$@/release/${OUT_FILE_NAME} ${OUT_PATH}/$@/${OUT_FILE_NAME}; \
	docker rm $(shell docker ps -a -f status=created -q);

aarch64-apple-darwin:
	cargo build --release
	cp ./target/release/libdji_log_parser_c.a ./bin/aarch64-apple-darwin/

copy-artifacts:
	cp bin/aarch64-unknown-linux-gnu/${OUT_FILE_NAME} ../flight-management/fileparser/dji/lib/aarch64-unknown-linux-gnu/release/
	cp bin/x86_64-unknown-linux-gnu/${OUT_FILE_NAME} ../flight-management/fileparser/dji/lib/x86_64-unknown-linux-gnu/release/
	cp bin/aarch64-apple-darwin/${OUT_FILE_NAME} ../flight-management/fileparser/dji/lib/aarch64-apple-darwin/release/
	cp ./dji-log-parser-c/include/dji-log-parser-c.h ../flight-management/fileparser/dji/include/

#==============================
# Meta
#==============================
help: ## Print help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

