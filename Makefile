.PHONY: install update link help

SHELL := /bin/bash

help:
	@echo "core-utils — cross-platform CLI environment"
	@echo ""
	@echo "  make install   Install packages + link configs (full setup)"
	@echo "  make update    Pull latest changes + re-link"
	@echo "  make link      Symlink configs only (requires stow)"
	@echo ""

install:
	@bash bootstrap.sh install

update:
	@bash bootstrap.sh update

link:
	@bash link.sh
