#!/usr/bin/env bash

_get_blog_name()
{
    # Extract the configuration file
    conf=`cat .blog.conf`
    #echo $conf
    name_regex="blog\:([a-zA-Z ]+)"

    # Echo the name of the blog, if any was given
    if [[ $conf =~ $name_regex ]]; then
        echo ${BASH_REMATCH[1]}
    fi
}

_get_dark_param()
{
    conf=`cat .blog.conf`
    dark_regex="dark:(y|n|N)"

    if [[ $conf =~ $dark_regex ]]; then
        echo ${BASH_REMATCH[1]}
    fi
}

_get_blog_lang()
{
    conf=`cat .blog.conf`
    lang_regex="lang:([a-z]+)"

    if [[ $conf =~ $lang_regex ]]; then
        echo ${BASH_REMATCH[1]}
    fi
}

_add_header()
{

    post_name=$1
    lang=$2
    dark=$3

    css="../css/poststyle.css"
    if [[ $dark =~ "y" ]]; then
      css="../css/poststyle.dark.css"
    fi

    cat > ./posts/$post_name.html << EOF
<!DOCTYPE html>
<html lang="$lang" dir="ltr">
    <head>
        <meta charset="utf-8">
        <title>$post_name</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <link href="https://fonts.googleapis.com/css?family=Cutive+Mono|IBM+Plex+Mono&display=swap" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="$css">
    </head>
    <body>
    <article class='post'>
EOF
}

_add_footer()
{
    post_name=$1
    cat >> ./posts/$post_name.html << EOF
    </article>
    <footer>
    </footer>
    </body>
</html>
EOF

}


_get_last_modif_date()
{
    # Extract the date of the last modification of the file $1
    # and echo it with format dd/mm/yyyy
    date=`stat -f "%Sm" -t "%d/%m/%Y" $1`
    echo $date
}

publish()
{
    delete_posts

    # Collect all configuration parameters so that the regex are only evaluted
    # once per publication. Done to improve the speed of the publication
    dark=$(_get_dark_param)
    lang=$(_get_blog_lang)
    blog_name=$(_get_blog_name)

    # list all the drafts stored as most recently modified to
    # least recently modified, as it should appear on a blog
    drafts=`ls -t ./drafts/`
    # echo $drafts

    # Tranform the string into an array
    list=($(echo "$drafts" | tr ' ' '\n'))

    # date=$(_get_last_modif_date "./drafts/${list[0]}")

    # Regex to extract the name without the extension
    name_regex="([a-zA-Z]+)\.(md|markdown)"

    # Array to story only the names of the posts
    posts_names=()

    for (( i=0; i<${#list[@]}; i++ ));
    do
        if [[ ${list[i]} =~ $name_regex ]]; then
            # Append the names to the array
            posts_names+=(${BASH_REMATCH[1]})
        fi
        _create_posts "./drafts/${list[i]}" "$lang" "$dark"
    done

    # function to update the index.html
    # Passing the drafts as argument since it's sorted
    _update_index "$drafts" "$blog_name" "$lang" "$dark"
}

_create_posts()
{
    draft=$1
    lang=$2
    dark=$3

    # Convert the markdown file $draft into html
    # and store the result in $content
    content=`multimarkdown --nolabels $draft`

    # Regex to extract the simple post name
    md_regex="([a-zA-Z]+)\.(md|markdown)"

    if [[ $draft =~ $md_regex ]]; then
        # If the file have md or markdown extension, cut it
        post_name=${BASH_REMATCH[1]}
    else
        # if not and it has no extension, keep it this way
        post_name=$draft
    fi

    # Integrate the html converted content into a proper html file
    _build_post "$post_name" "$content" "$lang" "$dark"
}

_build_post()
{
    # Create the html file of the post $post_name with the
    # previsouly converted markdown to html $content
    post_name=$1
    content=$2
    lang=$3
    dark=$4

    _add_header "$post_name" "$lang" "$dark"
    echo $content >> ./posts/$post_name.html
    _add_footer "$post_name"
}

_update_index()
{
    title=$2
    lang=$3
    dark=$4

    css="./css/indexstyle.css"
    if [[ $dark =~ "y" ]]; then
      css="./css/indexstyle.dark.css"
    fi

    cat > index.html << EOF
<!DOCTYPE html>
<html lang="$lang" dir="ltr">
  <head>
      <meta charset="utf-8">
      <title>$title</title>
      <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
      <link href="https://fonts.googleapis.com/css?family=Cutive+Mono|IBM+Plex+Mono&display=swap" rel="stylesheet">
      <link rel="stylesheet" type="text/css" href="$css">
  </head>
  <body>
      <h1 class='title'>$title</h1>
EOF

# Retrieve the string containing all drafts names and splitting it
# into an array
drafts=$1
drafts_list=($(echo "$drafts" | tr ' ' '\n'))

# Number of posts in the draft list, needed for the for loop
nbposts=${#drafts_list[@]}

# If there are posts to post, begin the list
if [ $nbposts -gt 0 ]
then
    echo "<ul class='posts_list'>" >> index.html
fi

# Regex to extract just the name of the post
post_regex="([a-zA-Z]+)\.md"

for (( i=0; i<${#drafts_list[@]}; i++ ));
do
    # Retrieve the date of the last modification of the draft
    date=$(_get_last_modif_date "./drafts/${drafts_list[i]}")

    # In case the next regex doesn't work, even though it's supposed to
    # work everytime
    post_name="unknown"

    # Extract the strict name of the post in the same
    # order of the drafts because they are sorted according
    # to the last modification date
    if [[ ${drafts_list[i]} =~ $post_regex ]]; then
        post_name=${BASH_REMATCH[1]}
    fi

    # Function to add items to the posts list
    _add_post_link "./posts/$post_name.html" "$post_name" "$date"

done

# If there are posts posted, close the list
if [ $nbposts -gt 0 ]; then
    echo "</ul>" >> index.html
fi

cat >> index.html << EOF
  </body>
</html>
EOF
}

_add_post_link()
{
    url=$1
    post_name=$2
    date=$3
    echo "<li class='post'>" >> index.html
    echo "<a href="$url">$post_name</a>" >> index.html
    echo "<span class='date'>$date</span>" >> index.html
    echo "</li>" >> index.html
}

init()
{
    echo Name of the author of the blog :
    read author
    echo "author:$author" > .blog.conf
    echo Name of the blog :
    read blog
    echo "blog:$blog" >> .blog.conf
    echo "Language of the blog : (en)"
    read lang
    if [ -z $lang ]; then
        lang=en
    fi
    echo "lang:$lang" >> .blog.conf
    echo "Activate dark mode : (y/N)"
    read dark
    if [ -z $lang ]; then
        dark=N
    fi
    echo "dark:$dark" >> .blog.conf
    mkdir drafts
    mkdir posts
    mkdir css
    _init_css
    _index "$blog" "$lang"
}

_init_css()
{
    # Initiate css files for both the index and the posts,
    # both dark and light themes
    cat > ./css/indexstyle.css << EOF
    .wrap {
      width: 40vw;
      margin-right: auto;
      margin-left: auto;
  }
    .title {
      margin-top: 5vh;
      margin-bottom: 7vh;
      text-align: center;
      font-family: 'IBM Plex Mono', monospace;
  }
    .posts_list {
      text-align: center;
      padding-left: 0px;
      list-style: none;
  }
    .post {
      margin-bottom: 3vh;
      font-family: 'IBM Plex Mono', monospace;
  }
    .post a:link {
      text-decoration: none;
  }
    .post a:hover {
      text-decoration: underline;
      color: #AAA;
  }
    .post a {
      color: black;
  }
    .date {
      color: #777;
      font-family: 'Cutive Mono', monospace;
  }
EOF

cat > ./css/indexstyle.dark.css << EOF
body {
  background: #222;
}
.wrap {
  width: 40vw;
  margin-right: auto;
  margin-left: auto;
}
.title {
  margin-top: 5vh;
  margin-bottom: 7vh;
  color: #e1e1e1;
  text-align: center;
  font-family: 'IBM Plex Mono', monospace;
}
.posts_list {
  text-align: center;
  padding-left: 0px;
  list-style: none;
}
.post {
  margin-bottom: 3vh;
  color: #e1e1e1;
  font-family: 'IBM Plex Mono', monospace;
}
.post a:link {
  color: #e1e1e1;
  text-decoration: none;
}
.post a:hover {
  text-decoration: underline;
  color: #AAA;
}
.post a {
  color: #e1e1e1;
}
.date {
  color: #777;
  font-family: 'Cutive Mono', monospace;
}
EOF

cat > ./css/poststyle.css << EOF
body {
  font-family: 'IBM Plex Mono', monospace;
}
.post {
  width: 70vw;
  margin-right: auto;
  margin-left: auto;
}
EOF

cat > ./css/poststyle.dark.css << EOF
body {
  font-family: 'IBM Plex Mono', monospace;
  background: #222;
  color: #e1e1e1;
}
.post {
  width: 70vw;
  margin-right: auto;
  margin-left: auto;
}
EOF

}

_index()
{
    title=$1
    lang=$2
    # Create the first index file, empty of any posts
    cat > index.html << EOF
<!DOCTYPE html>
<html lang="$lang" dir="ltr">
    <head>
        <meta charset="utf-8">
        <title>$title</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <link href="https://fonts.googleapis.com/css?family=Cutive+Mono|IBM+Plex+Mono&display=swap" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="./css/indexstyle.css">
    </head>
    <body>
        <h1 class='title'>$title</h1>
    </body>
</html>
EOF
}

change_mode()
{
    # READ FILE LINE BY LINE SO THAT THE NEW CONF FILE IS NOT ON ONE LINE
    echo "Activate dark mode : (y/N)"
    read dark
    if [ -z $lang ]; then
        dark=N
    fi
    conf=`cat .blog.conf`
    echo ${conf//dark:(y|n|N)/dark:$dark} > .blog.conf
}

delete_posts()
{
    rm ./posts/*.html
}

usage()
{
    echo
    echo "This script is made for those who want to blog and are also addicted
    to the command line"
    echo
    echo "Run the initiation for a start. After that, place all your future blog
    posts, written in markdown (.md or .markdown), in the draft folder."
    echo
    echo "Once you publish your blog, all the drafts in the said folder will be
    converted to html, added to the posts folder and append to the index.html"
    echo
    echo "To remove a post, just remove it from the draft folder and republish
    your blog"
    echo
    echo "blog usage :"
    echo "  -h  Display this help"
    echo "  -i  initiate the blog"
    echo "  -p  publish the blog"
    echo "  -d  delete the posts"
    echo "  -m  change mode of the blog (dark or light)"
    echo "  -n  change the name of the blog (not implemented yet)"
    echo "  -l  change the language of the blog (not implemented yet)"
}

while getopts ":ihpdm" opt; do
    case ${opt} in
        i )
            init
            ;;
        p )
            publish
            ;;
        h )
            usage
            ;;
        m )
            change_mode
            ;;
        d )
            delete_posts
            ;;
        \? )
            usage
            ;;
        : )
            usage
            ;;
    esac
done