#!/usr/bin/perl
use HTML::WikiConverter;

my $html = "<a href='page?MyPage'>MyPage</a> <a href='page?mysecondpage'>mysecondpage</a> <a href='page?MyOtherPage'>my-other-page</a>";
my @dialects = HTML::WikiConverter->available_dialects;
foreach my $dialect ( @dialects ) {
  my $wc = new HTML::WikiConverter( dialect => $dialect, base_uri => "http://mywiki.net/wiki", wiki_uri => "page?" );
  my $wiki = $wc->html2wiki( html => $html );
  printf "The %s dialect gives:\t%s\n", $dialect, $wiki;
}

