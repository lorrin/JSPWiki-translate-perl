#!/bin/bash
# Fetches JSPWiki contents into local dump directory
JSPWIKI_HOST=your.host.name
JSPWIKI_PATH=wiki
rm -r attach/*
rm -r dump/*
wget --no-verbose --no-parent --no-host-directories --directory-prefix=dump -r --level=2 --include-directories=$JSPWIKI_PATH --reject 'Edit.jsp*,Diff.jsp*,PageInfo.jsp*' "http://$JSPWIKI_HOST/$JSPWIKI_PATH/Wiki.jsp?page=PageIndex"
rm dump/robots.txt;
for f in dump/wiki/Wiki.jsp?page*; do
  mv $f `echo $f | sed -e 's/wiki\/Wiki.jsp\?page=//'`;
done;
for f in PageIndex TextFormattingRules RecentChanges MoreTools OneMinuteWiki WikiEtiquette FullRecentChanges SandBox SystemInfo UndefinedPages EditPageHelp; do
  rm dump/$f;
done;
mv dump/wiki/attach .
mv dump/protected/wiki/attach/* ./attach/
rm -r dump/wiki
