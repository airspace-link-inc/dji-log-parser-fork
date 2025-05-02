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

copy-artifacts:
	cp bin/aarch64-unknown-linux-gnu/${OUT_FILE_NAME} ../flight-management/fileparser/dji/lib/aarch64-unknown-linux-gnu/release/libdji_log_parser.a
	cp bin/x86_64-unknown-linux-gnu/${OUT_FILE_NAME} ../flight-management/fileparser/dji/lib/x86_64-unknown-linux-gnu/release/libdji_log_parser.a
	cp ./dji-log-parser-c/include/dji-log-parser-c.h ../flight-management/fileparser/dji/include/dji-log-parser.h

#==============================
# Meta
#==============================
help: ## Print help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

