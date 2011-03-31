#Overview
These are some scripts to help with using [HTML::WikiConverter](http://search.cpan.org/dist/HTML-WikiConverter/lib/HTML/WikiConverter.pm) and [HTML::WikiConverter-MoinMoin](http://search.cpan.org/~diberri/HTML-WikiConverter-MoinMoin/lib/HTML/WikiConverter/MoinMoin.pm) to translate from [JSPWiki](http://www.jspwiki.org/) to [MoinMoin](http://moinmo.in/). I recommend using my [patched version of HTML::WikiConverter-MoinMoin](https://github.com/lorrin/HTML-WikiConverter-MoinMoin).

##Workflow

1. Use `./fetch_all.sh` to pull in HTML generated from JSPWiki
1. Use `./translate.pm` to translate into MoinMoin format
1. Use `./push.sh` to push into locally installed MoinMoin server (launched with python wikiserver.py)
1. If things look good, copy out to remote MoinMoin server

##Hints
Installing HTML::WikiConverter is not straight-forward; it requires an older version of [Parse::RecDescent](http://search.cpan.org/~dconway/Parse-RecDescent/lib/Parse/RecDescent.pm). [Parse-RecDescent-1.962](http://backpan.perl.org/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.962.0.tar.gz) is available from [BackPan](http://backpan.perl.org/) and works. The prep work before using the scripts here is therefore:

1. Manually build and install (`perl Build.PL; ./Build; sudo ./Build install`) Parse-RecDescent from BackPan source
1. Install HTML::WikiConverter via CPAN
1. Manually install HTML::WikiConverter-MoinMoin from GitHub source

You'll probably have to install quite a few prerequisites as well. Attempting to install HTML::WikiConverter and letting run until it fails with the current Parse-RecDescent version is a good start.
