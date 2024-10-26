#!/usr/bin/env bash

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color (reset)

echo -e "${YELLOW}Testing markown parser :${NC}\n"

./test/parser/test_md_parser.sh ./lib/markdown.awk awk

echo -e "${YELLOW}Testing bob init :${NC}\n"

author="author"
blog="blog"
lang="fr"
dark="y"

./bob2 init << EOF
$author
$blog
$lang
$dark
EOF

conf_author=$(grep "^author=" .blog.conf | cut -d '=' -f 2)
conf_blog=$(grep "^blog=" .blog.conf | cut -d '=' -f 2)
conf_lang=$(grep "^lang=" .blog.conf | cut -d '=' -f 2)
conf_dark=$(grep "^dark=" .blog.conf | cut -d '=' -f 2)

rm -r posts
rm -r drafts