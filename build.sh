#!/bin/bash
cd _site
rsync -r atom.xml rss.xml index.html css imgs ..
cd compiler-hacking
rsync -r * ../../
