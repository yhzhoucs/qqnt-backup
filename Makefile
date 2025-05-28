PYTHON       ?= python

QQNT_BACKUP_URL  := https://github.com/xCipHanD/qqnt_backup/archive/refs/heads/main.tar.gz
QQNT_EXPORT_URL  := https://github.com/Tealina28/QQNT_Export/archive/refs/tags/v2.3.0.tar.gz

# Default target
.DEFAULT_GOAL := help

# Helper macros
define DL
	curl -L $(1) -o $(2)
endef

define UNZIP
	mkdir -p $(2) && tar xf $(1) --strip-components 1 -C $(2)
endef

help:
	@echo "Usage:"
	@echo "  make prepare               Download and patch dependencies"
	@echo "  make convert UID=... DBPATH=...     Run conversion"
	@echo "  make clean                 Clean all generated files"

check_inputs:
	@if [ -z "$(UID)" ] || [ -z "$(DBPATH)" ]; then \
		echo "Please provide UID and DBPATH like this: make UID=u_xxx DBPATH=..."; \
		false; \
	fi

# Download tarballs
deps:
	@mkdir -p deps

deps/qqnt_backup-main.tar.gz: deps
	@$(call DL, $(QQNT_BACKUP_URL), $@)

deps/QQNT_Export-v2.3.0.tar.gz: deps
	@$(call DL, $(QQNT_EXPORT_URL), $@)

# prepare code
qqnt_backup: deps/qqnt_backup-main.tar.gz
	$(call UNZIP, $<, qqnt_backup)
	patch -p1 -d qqnt_backup < ./patches/qqnt_backup-001-add-cmd-input.patch

QQNT_Export: deps/QQNT_Export-v2.3.0.tar.gz
	$(call UNZIP, $<, QQNT_Export)
	patch -p1 -d QQNT_Export < ./patches/QQNT_Export-001-modify-output-path.patch

prepare: qqnt_backup QQNT_Export

convert: check_inputs qqnt_backup QQNT_Export
	[ -d decrypt_dbs ] && rm -rf decrypt_dbs || true
	$(PYTHON) ./qqnt_backup/decrypt.py $(UID) $(DBPATH)
	$(PYTHON) ./QQNT_Export/main.py ./decrypt_dbs --output_path plaintext

clean: clean
	rm -rf output

.PHONY: prepare convert clean check_inputs help
