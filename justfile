set dotenv-load

alias r := run

bt := '0'

log := "warn"

export JUST_LOG := log
export ROCKET_PORT := "3721"

image_name := "ghcr.io/optravis-llc/hurlalot_server"
hurl_opts := "--variables-file hurl.env.test --test"

@_list:
	just --list --unsorted

# Perform all verifications (compile, test, lint, etc.)
verify: test shutdown run-release api-test lint


# Run the service locally (from sources)
run:
	cargo shuttle run --port 3721

deploy:
    cargo shuttle deploy

# Watch the source files and run `just verify` when source changes
watch:
	cargo watch -- just verify

# Run the tests
test:
	cargo hack test --feature-powerset --locked
	cargo deny check licenses

# Run the static code analysis
lint:
	cargo fmt --all -- --check
	cargo hack clippy --feature-powerset --all-targets --workspace --locked
	cargo deny check

# Build docker image for testing
build:
	docker build -t {{image_name}} .

wait-for-api:
	hurl api/health.hurl --retry 60 {{hurl_opts}}

# run acceptance tests against the running test stack
api-test *args: wait-for-api
    hurl api/*.hurl {{hurl_opts}} {{args}}

# run all acceptance tests against the running test stack, including for non-implemented api
api-test-not-implemented *args: wait-for-api
    hurl api/**/*.hurl {{hurl_opts}} {{args}}

api-to-curl:
	hurl api/*.hurl --retry-max-count=60 --variables-file hurl.env.test --verbose &>> hurl.txt
	cat hurl.txt | grep '* curl' | cut -c 2- | sort --unique
	rm hurl.txt

# Install cargo dev-tools used by the `verify` recipe (requires rustup to be already installed)
install-dev-tools:
	rustup install stable
	rustup override set stable
	cargo install cargo-hack cargo-watch cargo-deny hurl

clean:
	rm -rf target
	rm -f Cargo.lock
	rm -rf node_modules


fmt:
  cargo fmt

# run the release process in dry run mode (requires `npm`, a `GITHUB_TOKEN` and a `CARGO_REGISTRY_TOKEN`)
release *args:
	npm install --no-save conventional-changelog-conventionalcommits @semantic-release/exec
	npx semantic-release {{args}}

shutdown:
    lsof -t -i:{{ROCKET_PORT}} | xargs -r kill

run-release: shutdown
    just run &

deploy:
	cargo-shuttle deploy