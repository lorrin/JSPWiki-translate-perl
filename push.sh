#!/bin/bash
# Takes files translated into MoinMoin format residing in moin dir and generates MoinMoin file structure into $DEST.
# Also copies attachments from JSPWiki attach/page_name structure to MoinMoin $DEST/page_name/attachments
DEST=moin-1.9.3/wiki/data/pages

function process_file {
    echo Pushing $1
    name=$(echo $1 | sed -e 's/moin\/\(.*\).txt/\1/');
    mkdir $DEST/$name
    mkdir $DEST/$name/revisions
    cp $1 $DEST/$name/revisions/00000001
    echo 00000001 > $DEST/$name/current
}

if [[ "$@" = "" ]]; then
    rm -r $DEST/*
    for f in moin/*; do
        process_file $f
    done;
    for page_folder in attach/*; do
      title=$(basename $page_folder)
      mkdir $DEST/$title/attachments
      for f in $page_folder/*; do
        echo "Grabbing attachment $f"
        cp $f $DEST/$title/attachments/
      done;
    done;

else
    for f in $@; do
        rm -r $DEST/$f
    done
    for f in $@; do
        process_file moin/$f.txt
    done
fi
