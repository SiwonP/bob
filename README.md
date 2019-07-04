# bob
![code size](https://img.shields.io/github/languages/code-size/SiwonP/bob.svg)

Bob is a small static generator, for those who wants to maintain a personal
website or blog, all from the command line.

## Installation

It only is designed in bash script, and should work perfectly fine on any Unix
like machine.

```
git clone https://github.com/SiwonP/bob.git
cd bob
make install
```

## Usage

For a start, to generate an empty blog, type in the following in the directory
where you want to put your blog in and follow the guide.

```
bob -i
```

It will create an `index.html` at the root of your folder, a `drafts` folder in
which you will store all the posts you want to publish and a `posts` folder
where the resulting posts in html will be stored.

To write a post, create a markdown file in the `drafts` folder whose name will
also be its title, and convert it to an html file, type the following command
from the root :

```
bob -p
```

The publishing command `bob -p` will rep-ublish all the drafts, that is why
anytime you want a post removed, delete in from the drafts folder and re-publish
your blog.

See the help for additional command, such as modification of the main configuration
of the blog.

```
bob -h
```

## TODO

* Make a proper header/footer for the posts (e.g. adding links to social networks
  such as tweeter, github, dev.to ...).
* Complete the CSS files.
* Support long arguments on the command line for more readability.
* Add a comment/like section ?
* Adding a git component, and a server configuration to allow synchronisation.
  Maybe the drafts folder on the personal computer triggers changes on the git
  repo of the server which re-publishes the blog automatically.
* Add a way to do all the construction of the blog on the personal computer but
  to send the html files to a distant server.
* Consider adding configuration files for some/all posts (if they
  need special javascript included e.g. MathJax, AJAX, sockets ...).
