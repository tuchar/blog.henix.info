.PHONY: all

.SECONDARY:

PAGEMD := $(wildcard *.md)
PAGES := $(patsubst %.md,%.html,$(PAGEMD))

all: index.html $(PAGES) root.css rss2.0.xml

sorted.row: $(wildcard */*/_.row)
	cat $^ | sort -t $$'\t' -r -k 1,1 > $@

index.html: sorted.row index.sh _.sitetitle _.siteurl $(wildcard */_.name) $(PAGEMD) ga.seg.htm
	./index.sh > $@

404.html: 404.md _.sitetitle _.siteurl page.temp.htm disqus.seg.htm ga.seg.htm
	pandoc -t html5 --template=page.temp.htm -A disqus.seg.htm -A ga.seg.htm -V id=$$(echo $< | sed -e 's/\.md$$//') -V "sitetitle=$$(< _.sitetitle)" -V "siteurl=$$(< _.siteurl)" --css="/root.css" -o $@ $<

%.html: %.md _.sitetitle _.siteurl page.temp.htm disqus.seg.htm ga.seg.htm
	pandoc -t html5 --template=page.temp.htm -A disqus.seg.htm -A ga.seg.htm -V id=$$(echo $< | sed -e 's/\.md$$//') -V "sitetitle=$$(< _.sitetitle)" -V "siteurl=$$(< _.siteurl)" --css=root.css -o $@ $<

root.css: root.scss
	compass compile --sass-dir . --css-dir .

rss2.0.xml: sorted.row rss.sh _.sitetitle _.siteurl _.sitedesc _.author $(wildcard */*/_.htm)
	./rss.sh > $@

clean:
	rm sorted.row index.html $(PAGES) rss2.0.xml
