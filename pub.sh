#!/bin/sh

rm -rf _build \
    && . sphinx-markdown/bin/activate \
    && make html \
    && rsync -av _build/html/ /var/www/html/
