#!/usr/bin/env bash

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset)

# Ensure a script is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <markdown_parser_script>"
  exit 1
fi


PARSER="$1"

# Check if the parser script exists
if [ ! -f "$PARSER" ]; then
  echo "Error: $PARSER not found!"
  exit 1
fi

# Determine if it's AWK or Shell (optional second argument)
PARSER_TYPE="bash"  # Default to bash script
if [ -n "$2" ]; then
  PARSER_TYPE="$2"
fi

# Define test cases as an array of markdown inputs and expected outputs
declare -a tests=(
  "Header 1"
  "# Header 1"
  "<h1>Header 1</h1>"

  "Header 2"
  "## Header 2"
  "<h2>Header 2</h2>"

  "Header 3"
  "### Header 3"
  "<h3>Header 3</h3>"

  "Header 4"
  "#### Header 4"
  "<h4>Header 4</h4>"

  "Header 5"
  "##### Header 5"
  "<h5>Header 5</h5>"

  "Header 6"
  "###### Header 6"
  "<h6>Header 6</h6>"

  "Multiple headers 1"
  $'# Header 1\n## Header 2'
  "<h1>Header 1</h1><h2>Header 2</h2>"

  # "Multiple headers 2"
  # $'### Header 3\n\n## Header 2\n\n# Header 1'
  # "<h3>Header 3</h3><h2>Header 2</h2><h1>Header 1</h1>"

  "Unordered List"
  $'- item\n* item'
  "<ul><li>item</li><li>item</li></ul>"

  "Ordered List"
  $'1. item1\n1. item1\n3. item3'
  "<ol><li>item1</li><li>item1</li><li>item3</li></ol>"

  "Blockquote 1"
  "> test of blockquote"
  "<blockquote>test of blockquote</blockquote>"

  "Blockquote 2"
  $'> line1\n> line2'
  "<blockquote>line1line2</blockquote>"
  
  "Blockquote 2"
  $'> line1\nline2'
  "<blockquote>line1line2</blockquote>"

  "Code Block 1"
  $'    code1'
  "<pre><code>code1</code></pre>"

  "Code Block 2"
  $'\tcode1'
  "<pre><code>code1</code></pre>"

  "Paragraph 1"
  "paragraph 1"
  "<p>paragraph 1</p>"

  "Paragraph 2"
  "paragraph *emphasis* and **strong**"
  "<p>paragraph <em>emphasis</em> and <strong>strong</strong></p>"

  "Mix Code blocks and paragraphs 1"
  $'First paragraph\n\n    code block'
  "<p>First paragraph</p><pre><code>code block</code></pre>"

  "Mix Code blocks and paragraphs 2"
  $'First paragraph\n\n    code1\n    code2\n\nSecond paragraph'
  "<p>First paragraph</p><pre><code>code1code2</code></pre><p>Second paragraph</p>"

  # You can add more test cases following the same format...
)

input="# test"
expected="<h1>test</h1>"

# Function to run a single test case
run_test() {
  local input="$1"
  local expected="$2"
  local actual=""

  # Get the actual output from the parser
  if [ "$PARSER_TYPE" == "awk" ]; then
    # Run AWK script with the input
    actual=$(echo "$input" | awk -f "$PARSER" | tr -d '\n')
  else
    # Assume it's a shell script, run it
    actual=$(echo "$input" | bash "$PARSER" | tr -d '\n')
  fi

  # Compare the actual output with the expected output
  if [ "$actual" == "$expected" ]; then
    echo -e "${GREEN}Test Passed!${NC}"
  else
    echo -e "${RED}Test Failed!${NC}"
    echo "Input:"
    echo "$input"
    echo "Expected:"
    echo "$expected"
    echo "Got:"
    echo "$actual" 
  fi
}

# Main loop to run all test cases
num_tests=$((${#tests[@]} / 3))  # Divide by 2 because each test has input/output pair
for ((i = 0; i < num_tests; i++)); do
  input="${tests[i * 3 + 1]}"
  expected="${tests[i * 3 + 2]}"
  echo "Test $((i + 1)):" ${tests[i * 3]}
  run_test "$input" "$expected"
done
