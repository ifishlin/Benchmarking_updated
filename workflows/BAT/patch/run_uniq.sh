#!/bin/bash

for f in *.bedgraph; do
   echo $f
   bname=$(echo $f|rev|cut -f2- -d "."|rev)
   uniq $f > $bname"".uniq.bedgraph &
done
