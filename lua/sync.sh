#!/bin/sh
rsync -avz --delete output/blog ../static/
rsync -avz output/*.html ../static/
rsync -avz output/rss2.0.xml ../static/
