#!/bin/bash
dir=../../`echo $1 | sed 's,.ml,,'`
if [ -d $dir ]; then
  pushd $dir > /dev/null
    to_include=""
    for i in `ls *.ml 2> /dev/null`; do
      a=`basename $dir | sed -r 's,^(.)(.*),\\1 \\2,' | awk '{ print toupper(\$1) \$2 }'`
      b=`echo ${i} | sed -r 's,^(.)(.*).ml,\\1 \\2,' | awk '{ print toupper(\$1) \$2 }'`
      if grep -q "\(\* subdirs: no alias \*\)" $i; then
        if grep -q '^module ToInclude2 = ' $i; then
          echo "(* subdir ml has ToInclude2 module *)"
        fi
        echo "(* unopened subdir ml: ${a}__${b} *)"
      else
        echo "module $b = ${a}__${b}"
        if grep -q '^module ToInclude = ' $i; then
          echo "include ${b}.ToInclude"
        fi
      fi
      #awk '/^\(\* subdir ml has ToInclude2 module \*\)\(\* unopened subdir ml: Category__Id__Function \*\)/ { print "include " $11 ".ToInclude2" }' $1
    done
  popd > /dev/null
fi
sed -r 's,^\[@@@(include.*)\]$,#\1,;s,([a-z]) \(,\1\(,g' $1 > $1.cppo
cppo -I ../../`dirname $1 | sed 's,\/\.submodules,,'`/include -I $dir/.include $1.cppo | awk -f ../../scripts/random.awk
