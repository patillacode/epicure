COVERAGE = $(VENV)coverage
GIT = git
PIP = $(VENV)pip
PYTEST = $(VENV)pytest
PYTHON = $(VENV)python
PYTHON_GLOBAL = python3
VENV = venv/bin/

.PHONY: demo install reset-requirements


# utils
demo:
	$(info Running demo...)
	@$(PYTHON) -m epicure.demo

create-venv:
	$(info Creating virtual environment...)
	@$(PYTHON_GLOBAL) -m venv venv

upgrade-pip:
	$(info Upgrading pip...)
	@$(PIP) install --upgrade pip

install-package:
	$(info Installing package in editable mode...)
	@$(PIP) install -e .

tag:
	$(info Tagging commit...)
	@$(GIT) tag v$(shell $(BAMP) current)

current-branch:
	@$(GIT) rev-parse --abbrev-ref HEAD

push:
	$(info Pushing commit and tag...)
	@$(GIT) push origin $(shell $(GIT) rev-parse --abbrev-ref HEAD)
	@$(GIT) push --tags

install: create-venv upgrade-pip dev-requirements install-package

# tests
test:
	$(info Running tests...)
	@$(PYTEST) -x

coverage-report:
	@$(COVERAGE) run -m pytest -x
	@$(COVERAGE) json -o "coverage-summary.json"
	@$(COVERAGE) report -m



# requirements
build-dev-requirements:
	$(info Building development requirements...)
	@$(VENV)pip-compile requirements/development.in -o requirements/development.txt

build-production-requirements:
	$(info Building production requirements...)
	@$(VENV)pip-compile requirements/base.in -o requirements/production.txt

build-test-requirements:
	$(info Building test requirements...)
	@$(VENV)pip-compile requirements/test.in -o requirements/test.txt

install-development-requirements:
	$(info Installing development requirements...)
	@$(PIP) install -r requirements/development.txt

install-production-requirements:
	$(info Installing production requirements...)
	@$(PIP) install -r requirements/development.txt

install-test-requirements:
	$(info Installing test requirements...)
	@$(PIP) install -r requirements/test.txt

delete-requirements-txt:
	$(info Resetting requirements...)
	@rm -f requirements/*.txt


# requirements aliases
build-requirements: build-dev-requirements build-production-requirements build-test-requirements
dev-requirements: build-dev-requirements install-development-requirements
prod-requirements: build-production-requirements install-production-requirements
test-requirements: build-test-requirements install-test-requirements

reset-requirements: delete-requirements-txt build-requirements

test-pypi-release:
	$(info Removing old build...)
	rm -rf dist/ build/ *.egg-info/
	$(info Make sure to have the latest version of build & twine...)
	@$(PYTHON) -m pip install --upgrade build twine
	$(info Building new version...)
	@$(PYTHON) -m build
	$(info Publishing to test.pypi.org...)
	@$(PYTHON) -m twine upload --repository testpypi dist/* --verbose

pypi-release:
	$(info Removing old build...)
	rm -rf dist/ build/ *.egg-info/
	$(info Make sure to have the latest version of build & twine...)
	@$(PYTHON) -m pip install --upgrade build twine
	$(info Building new version...)
	@$(PYTHON) -m build
	$(info Publishing to pypi.org...)
	@$(PYTHON) -m twine upload dist/* --verbose
