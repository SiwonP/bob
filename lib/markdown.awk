#!/usr/bin/awk

BEGIN {
    env = "none"
    stack_pointer = 0
    push(env)
}

# Function to push a value onto the stack
function push(value) {
    stack_pointer++
    stack[stack_pointer] = value
}

# Function to pop a value from the stack (LIFO)
function pop() {
    if (stack_pointer > 0) {
        value = stack[stack_pointer]
        delete stack[stack_pointer]
        stack_pointer--
        return value
    } else {
        return "empty"
    }
}

# Function to get last value in LIFO
function last() {
    return stack[stack_pointer]
}

function replaceEmAndStrong(line,   result, start, end) {
    # Replace occurrences of **...** with <strong>...</strong>
    while (match(line, /\*\*([^*]+)\*\*/)) {
        start = RSTART
        end = RSTART + RLENGTH - 1
        # Build the result: before match, <strong>, content, </strong>, after match
        line = substr(line, 1, start-1) "<strong>" substr(line, start+2, RLENGTH-4) "</strong>" substr(line, end+1)
    }

    # Replace occurrences of *...* with <em>...</em>
    while (match(line, /\*([^*]+)\*/)) {
        start = RSTART
        end = RSTART + RLENGTH - 1
        # Build the result: before match, <em>, content, </em>, after match
        line = substr(line, 1, start-1) "<em>" substr(line, start+1, RLENGTH-2) "</em>" substr(line, end+1)
    }

    return line
}


function closeOne() {
    env = pop()
    print "</" env ">"
}

# Matching headers
/^#+ / {
    match($0, /#+ /);
    n = RLENGTH;
    print "<h" n-1 ">" substr($0, n + 1) "</h" n-1 ">" 
}

# Matching blockquotes
/^> / {
    env = last()
    if (env == "blockquote")
    {
        # In a blockquote block only print the text
        print substr($0, 3);
    } else {
        # Otherwise, init the blockquote block 
        push("blockquote")
        print "<blockquote>\n" substr($0, 3)
    }
}

# Matching unordered lists
/^[-+*] / {
    env = last()
    if (env == "ul" ) {
        # In a unordered list block, print a new item 
        print "<li>" substr($0, 3) "</li>" 
    } else {
        # Otherwise, init the unordered list block 
        push("ul")
        print "<ul>\n<li>" substr($0, 3) "</li>"
    }
}

# Matching ordered lists 
/^[0-9]+\./ {
    env = last()
    if (env == "ol") {
        # In a ordered list block, print a new item 
        print "<li>" substr($0, 4) "</li>"
    } else {
        # Otherwise, init the ordered list block 
        push("ol")
        print "<ol>\n<li>" substr($0, 4) "</li>"
    }
}

# Matching code block
/^(    |\t)/ {
    env = last()
    match($0, /(    |\t)/);
    n = RLENGTH;
    if (env == "code") {
        # In a code block, print a new item 
        print  substr($0, n+1)
    } else {
        # Otherwise, init the code block 
        push("pre")
        push("code")
        print "<pre><code>" substr($0, n+1)
    }
}


# Matching a simple paragraph
!/^(#|\*|-|\+|>|`|$|\t|    )/ {
    env = last() 
    if (env == "none") {
        # If no block, print a paragraph
        print "<p>" replaceEmAndStrong($0) "</p>"
    } else if (env == "blockquote") {
        print $0
    }
}

$0 == "" {
    env = last()
    while (env != "none") {
        env = pop()
        print "</" env ">"
        env = last()
    }
}


END {
    env = last()
    while (env != "none") {
        env = pop()
        print "</" env ">"
        env = last()
    }
}