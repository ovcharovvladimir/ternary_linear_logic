#!/bin/bash
dir=`echo $1 | sed 's,.ml,,'`
if [ -d $dir ]; then
  if [ ! -d $dir/.include ]; then
    mkdir -p $dir/.include/self
  fi
  pushd $dir/.include/self > /dev/null
    ln -sf ../../*.ml.cppo ./
  popd > /dev/null
  pushd $dir > /dev/null
    for i in `ls *.ml 2> /dev/null`; do
      sdir=`echo $i | sed 's,.ml,,'`
      u=`echo ${i} | sed -r 's,^(.)(.*),\\1 \\2,' | awk '{ print toupper(\$1) \$2 }'`
      w=`echo ${sdir} | sed -r 's,^(.)(.*),\\1 \\2,' | awk '{ print toupper(\$1) \$2 }'`
      q=${PWD}__${u}
      p=${PWD}__${w}
      sba=$PWD/../.submodules/
      sb=$(echo $sba | sed -r 's,/.submodules/.*,/.submodules/,g')
      dune=$( echo $sb/../dune | sed -r 's,/[^/]+/+\.\.,,g' )
      if [ -f $dune ]; then
        dunedir=$( echo $sb/../ | sed -r 's,/[^/]+/+\.\.,,g' )
        ln -Pf $PWD/$i $q
        #cp $PWD/$i $q
        mkdir -p $sb
        mv $q $sb 2> /dev/null
        if [ -d $PWD/$sdir ]; then
          ln -sf $PWD/$sdir $p
          mv $p $sb 2> /dev/null
        fi
        rm -f $dunedir/*__*
      fi
    done
  popd > /dev/null
fi
