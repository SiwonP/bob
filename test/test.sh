#!/usr/bin/env bash

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color (reset)

echo -e "${YELLOW}Testing markown parser :${NC}\n"

./parser/test_md_parser.sh ../lib/markdown.awk awk
