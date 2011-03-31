#!/usr/bin/env perl -w
# Uses HTML::WikiConverter to translate from JSPWiki-generated HTML to MoinMoin format. 
# Code here is almost completely destination-agnostic and primarily serves to sanitize the
# JSPWiki HTML.
# Reads from "dump" and writes to "moin"

use HTML::WikiConverter;
use HTML::Entities;

my $base_uri = 'http://your.host.name/path/';
my $wiki_uri = "Wiki.jsp?page=";

# Find first node to the left of this one, walking up through ancestors until
# one with a left sibling or the root node is reached.
sub find_preceding_content_node {
  ( $node ) = @_;
  if ($node->left()) {
    return $node->left();
  } elsif ( $node->parent() ) {
    return find_preceding_content_node($node->parent());
  } else {
    return undef;
  }
};

my $jspwiki_tidy = sub {
  # Only keep body -> div #container -> div #middle
  ( $root ) = @_;
  $content = $root->
    look_down("_tag", "body")->
      look_down("_tag", "div", "id", "container")->
        look_down("_tag", "div", "id", "middle");
  $content->detach();
  $root->delete_content();
  $root->push_content($content);

  # remove BR at the end of the content block, and anything that comes after it (Attachment: table).
  $br = $content->look_down("_tag","br","clear","all");
  if ($br) {
    foreach $e ($br->right()) {
      $e->delete();
    }
    $br->delete();
  }

  # remove the off-site icons JSPWiki adds
  foreach $outlink_image ($content->look_down("_tag","img","class","outlink")) {
    $outlink_image->delete();
  }

  # remove the extra-info paperclip links for attachments
  $lookfor = $base_uri . "PageInfo.jsp\\?page=.*";
  foreach $attachment_info ($content->look_down("_tag","a")) {
    if ($attachment_info->attr("href") && $attachment_info->attr("href") =~ /$lookfor/) {
      $attachment_info->delete();
    }
  }



  # If you try to put {{{ }}} inline in JSPWiki, instead of a <pre> tag you get
  # <span style="font-family:monospace; whitespace:pre;">. (But I never set up the
  # CSS right for this, so it renders crap in the browser!) This then parses
  # as a <span style=whitespace: pre"><font face="monospace">... pair.
  foreach $span_node ($content->look_down("_tag","span","style","whitespace: pre")) {
    $font_node = $span_node->look_down("_tag","font","face","monospace");
    if ($font_node) {
      $text_node = $font_node->look_down("_tag","~text");
      $text_node->detach();
      $tt = HTML::Element->new("tt");
      $tt->push_content($text_node);
      $span_node->replace_with($tt);
    }
  }

  #Remove annoying "Wikipedia:" prefix from links to Wikipedia
  foreach $a_node ($content->look_down("_tag","a")) {
    $text_node = $a_node->look_down("_tag","~text");
    if ($text_node) {
      $text = $text_node->attr("text");
      $text =~ s/^Wikipedia://;
      if ($text ne $text_node->attr("text")) {
        $text_node->attr("text", $text);
      }
    }
  }

  #Preprocess links to attachments from attach/... to attachment:...
  #That's a bit uncouth, since it's a MoinMoin specific translation.
  foreach $img_node ($content->look_down("_tag","img")) {
    $src = $img_node->attr("src");
    if ($src) {
      $search_for = $base_uri . "attach/[^/]+";
      $src =~ s/^$search_for\//attachment:/;
      if ($src ne $img_node->attr("src")) {
        $img_node->attr("src", $src);
      }
    }
  }
  foreach $a_node ($content->look_down("_tag","a")) {
    $href = $a_node->attr("href");
    if ($href) {
      $search_for = $base_uri . "attach/[^/]+";
      $href =~ s/^$search_for\//attachment:/;
      if ($href ne $a_node->attr("href")) {
        $a_node->attr("href", $href);
      }
    }
  }

  #JSPWiki is lax about its <p> tags. Often generates output such as:
  #<h1>heading</h1>
  #Some text.
  #
  #The translation process preserves the whitespace betwen the heading and the
  #text:
  #= heading =
  # Some text.
  #
  #Causing an undesired indent of the paragraph.
  #
  #Address this by stripping all leading whitespace from text nodes that are
  #preceded by block-style tags.
  foreach $text_node ($content->look_down("_tag","~text")) {
    $uncle_node = find_preceding_content_node($text_node);
    $trim = (not $uncle_node) || $uncle_node->tag =~ m/^(h[1-9]|p|pre|[oud]l|div|hr|br)$/;
    if ($trim) {
      $trimmed_text = $text = $text_node->attr("text");
      $trimmed_text =~ s/^\s+//;
      if ($trimmed_text ne $text) {
        #print "Trimmed '$text' -> '$trimmed_text'\n";
      }
      $text_node->attr("text", $trimmed_text);
    } 
  }
  #print $content->dump();
};

my $wc = new HTML::WikiConverter(
  dialect => 'MoinMoin',
  preprocess => $jspwiki_tidy,
  enable_anchor_macro => 1,
  escape_entities => 0,
  base_uri => $base_uri,
  wiki_uri => $wiki_uri
  );

mkdir("moin");
opendir(DIR, "dump");
@files = readdir(DIR);
closedir(DIR);

if ( $#ARGV == 0 ) {
  $filePattern = $ARGV[0];
  print "Translating files matching provided filter regex '$ARGV[0]'.\n";
} else {
  $filePattern = "[^.]"; #ignore . and .. files
  print "No file regex specified. Translating all files.\n";
}

foreach $file (@files) {
  if ($file =~ $filePattern) {    
    #Translation is white-space sensitive. Had hoped Tidy would resolve whitespace
    #issues, but it leaves too much in.
    #print "Tidying " . $file . "\n";
    #`tidy -quiet -asxhtml -f /dev/null -output tidy/$file.html dump/$file`;
    print "Translating " . $file . "\n";
    open (my $outputfile, ">", "moin/" . $file . ".txt") || die "\n   Could not create write file.\n\n";
    print $outputfile $wc->html2wiki( file => "dump/".$file );
    close $outputfile;
  }
}
