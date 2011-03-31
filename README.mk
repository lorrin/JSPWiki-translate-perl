These are some scripts to help with using [http://search.cpan.org/dist/HTML-WikiConverter/lib/HTML/WikiConverter.pm](HTML::WikiConverter) and [http://search.cpan.org/~diberri/HTML-WikiConverter-MoinMoin/lib/HTML/WikiConverter/MoinMoin.pm](HTML::WikiConverter-MoinMoin) to translate from [http://www.jspwiki.org/](JSPWiki) to [http://moinmo.in/](MoinMoin). I recommend using my [https://github.com/lorrin/HTML-WikiConverter-MoinMoin](patched version of HTML::WikiConverter-MoinMoin).

Intended workflow is:
1. Use ./fetch_all.sh to pull in HTML generated from JSPWiki
2. Use ./translate.pm to translate into MoinMoin format
3. Use ./push.sh to push into locally installed MoinMoin server (launched with python wikiserver.py)
4. If things look good, copy out to remote MoinMoin server

Installing HTML::WikiConverter is not straight-forward; it requires an older version of [http://search.cpan.org/~dconway/Parse-RecDescent/lib/Parse/RecDescent.pm](Parse::RecDescent).[http://backpan.perl.org/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.962.0.tar.gz](Parse-RecDescent-1.962) is available on backpan and works. The overall process is therefore:
1. manually build and install (perl Build.PL; ./Build; sudo ./Build install) Parse-RecDescent from Backpan source
2. Install HTML::WikiConverter via CPAN
3. manually install HTML::WikiConverter-MoinMoin from GitHub source
