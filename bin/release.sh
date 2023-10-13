#!/bin/bash
set -Eeuo pipefail

PATH="$HOME"/.cargo/bin:$PATH
export PATH
cargo build --release --verbose --locked

# Return PATH var to parent shell
package_dir="$(cd target/release ; pwd)"
echo "  export PATH=$package_dir:$PATH"