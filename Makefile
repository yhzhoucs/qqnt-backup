PYTHON       := python
THREAD_NUM   := 8

QQNT_BACKUP_URL  := https://github.com/xCipHanD/qqnt_backup/archive/main.zip
QQNT_EXPORT_URL  := https://github.com/Tealina28/QQNT_Export/archive/refs/tags/1.5.1.zip

# Default target
.DEFAULT_GOAL := help

# Helper macros
define DL
	curl -L $(1) -o $(2)
endef

define UNZIP
	unzip -q $(1) -d $(2)
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

# Download zip files
zips:
	@mkdir -p zips

zips/qqnt_backup-main.zip: zips
	@$(call DL, $(QQNT_BACKUP_URL), $@)

zips/QQNT_Export-1.5.1.zip: zips
	@$(call DL, $(QQNT_EXPORT_URL), $@)

# prepare code
qqnt_backup: zips/qqnt_backup-main.zip
	rm -rf qqnt_backup && mkdir qqnt_backup
	$(call UNZIP, $<, qqnt_backup)
	mv qqnt_backup/qqnt_backup-main/* qqnt_backup/
	rmdir qqnt_backup/qqnt_backup-main
	git apply --directory=qqnt_backup ./patches/qqnt_backup-001-add-cmd-input.patch

QQNT_Export: zips/QQNT_Export-1.5.1.zip
	rm -rf QQNT_Export && mkdir QQNT_Export
	$(call UNZIP, $<, QQNT_Export)
	mv QQNT_Export/QQNT_Export-1.5.1/* QQNT_Export/
	rmdir QQNT_Export/QQNT_Export-1.5.1
	git apply --directory=QQNT_Export ./patches/QQNT_Export-001-modify-output-path.patch

prepare: qqnt_backup QQNT_Export

convert: check_inputs
	$(PYTHON) ./qqnt_backup/decrypt.py $(UID) $(DBPATH)
	$(PYTHON) ./QQNT_Export/main.py ./decrypt_dbs $(THREAD_NUM)

clean: clean-cache
	rm -rf plaintext

clean-cache:
	rm -rf decrypt_dbs qqnt_backup QQNT_Export zips

.PHONY: prepare convert clean clean-cache check_inputs help
