PYTHON       := python
THREAD_NUM   := 8

QQNT_BACKUP_URL  := https://github.com/xCipHanD/qqnt_backup/archive/refs/heads/main.tar.gz
QQNT_EXPORT_URL  := https://github.com/Tealina28/QQNT_Export/archive/refs/tags/1.5.1.tar.gz

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
	@echo "  make clean-cache           Clean intermediate caches"

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

deps/QQNT_Export-1.5.1.tar.gz: deps
	@$(call DL, $(QQNT_EXPORT_URL), $@)

# prepare code
qqnt_backup: deps/qqnt_backup-main.tar.gz
	rm -rf qqnt_backup && mkdir qqnt_backup
	$(call UNZIP, $<, qqnt_backup)
	patch -p1 -d qqnt_backup < ./patches/qqnt_backup-001-add-cmd-input.patch

QQNT_Export: deps/QQNT_Export-1.5.1.tar.gz
	rm -rf QQNT_Export && mkdir QQNT_Export
	$(call UNZIP, $<, QQNT_Export)
	patch -p1 -d QQNT_Export < ./patches/QQNT_Export-001-modify-output-path.patch

prepare: qqnt_backup QQNT_Export

convert: check_inputs
	$(PYTHON) ./qqnt_backup/decrypt.py $(UID) $(DBPATH)
	$(PYTHON) ./QQNT_Export/main.py ./decrypt_dbs $(THREAD_NUM)

clean: clean-cache
	rm -rf plaintext

clean-cache:
	rm -rf decrypt_dbs qqnt_backup QQNT_Export deps

.PHONY: prepare convert clean clean-cache check_inputs help
