#!/usr/bin/env bash
# verify_openai_env.sh — check OPENAI_API_KEY is in env
set -euo pipefail

python3 - <<'EOF'
import os, sys
key = os.getenv("OPENAI_API_KEY")
if key:
    print("OK")
    sys.exit(0)
else:
    print("MISSING")
    sys.exit(1)
EOF

