#!/usr/bin/env VERSION=855 sh -x # <-- Update VERSION to correspond with drop.
URI=http://opensource.apple.com/tarballs/cctools/cctools-$VERSION.tar.gz

git checkout -b cctools-$VERSION 2>/dev/null || :

cp strip.c tease.c; git diff -R --histogram -- tease.c > /tmp/tease.patch
git checkout -- tease.c

curl -L\# $URI | tar x --strip-components 1; git checkout -- Makefile

for file in strip.c install_name_tool.c nm.c; do cp misc/$file .; done

git clean -dfq;       git add -A . && git commit -am "Import cctools-$VERSION."
cp strip.c tease.c;   git apply /tmp/tease.patch && success=yes || success=no
[ $success = yes ] && git add -A . && git commit -am  "Apply cctools-$VERSION."

[ $success = yes ] && exit 0 || git checkout -- tease.c; mv /tmp/tease.patch .
echo "Could not auto-apply patch. See strip.c, tease.c, tease.patch." && exit 1
