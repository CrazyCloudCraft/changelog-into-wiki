#!/bin/bash

#########
# some debug output to check in case of failures
# also exit on any error
set -xe

cd $1

# Get the md5change from the Changelog markdown file
md5=$(md5sum Changelog.md)

# Run the Changelog
rm -f Changelog.md
(
# exclude documents that you do not want to check
for i in $(find . -name '*.md' \
  '!' -name README.md \
  '!' -name Changelog.md | sort) ; do
  name=$(basename $i)
  name=${name/.md}
  cat $i | \
    # print everything after this point in the markdown
    sed -n -e '/## LAST PARAGRAPH TITLE/,$p' | \
    # replace title with name of the file
    sed -e 's@^## LAST PARAGRAPH TITLE@## '"$name"'@'
  echo
done
) > Changelog.md

# Compare md5 sumss
new_md5=$(md5sum Changelog.md)

echo "Old md5 change: $md5 ; New md5 change: $new_md5"

if [ "$md5" != "$new_md5" ] ; then
  # this is required for the push to succeed
  git config --global user.email "kontakt@buzcraft.de"
  git config --global user.name "CrazyCloudCraft"
  git add Changelog.md
  git commit -m "Update Changelog at $(date)"
  git push origin master
fi

exit 0
