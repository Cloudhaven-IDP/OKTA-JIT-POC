.PHONY: prereqs setup cleanup test opa lint

prereqs:
	./scripts/check-prereqs.sh

setup:
	./setup.sh

cleanup:
	./cleanup.sh

test:
	uv sync --frozen --group dev
	uv run pytest app/tests -v

opa:
	opa test infra/policies/

lint:
	uv run ruff check .
