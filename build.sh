#!/bin/sh
#

last_mod=`date +%s`
updated=0

for d in `find . -depth 1 -type d | cut -c3-`; do
  if [ "$d" = ".git" ]; then continue; fi

  cd "$d"
  tar -czf "temporary.tgz" "$d"
  if [ $? -eq 0 ]; then
    old_md5=`tar -tzvf "$d".tgz 2>/dev/null | md5 -r | cut -f1 -d" " 2>/dev/null`
    new_md5=`tar -tzvf temporary.tgz | md5 -r | cut -f1 -d" "`
    real_md5=`md5 -r temporary.tgz | cut -f1 -d" "`

    if [ "$old_md5" != "$new_md5" ]; then
      mv temporary.tgz "$d".tgz
      cat template_data.json | sed "s/__MD5SUM__/$real_md5/g" | sed "s/__LASTMOD__/$last_mod/g" >"$d".json
      git add "$d".tgz "$d".json
      updated=1
    fi
  fi

  rm -f temporary.tgz
  cd ..
done

if [ "$updated" -eq 1 ]; then
  cat template_master.json | sed "s/__LASTMOD__/$last_mod/g" >master.json
  git add master.json
fi
