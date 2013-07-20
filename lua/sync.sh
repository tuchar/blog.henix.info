#!/bin/sh
rsync -avz --delete blog ../static/
rsync -avz --delete tags ../static/
rsync -avz pages/index.html ../static/
rsync -avz pages/search.html ../static/
rsync -avz pages/links.html ../static/
rsync -avz pages/about.html ../static/
rsync -avz pages/guestbook.html ../static/
