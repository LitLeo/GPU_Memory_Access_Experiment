#!/bin/bash
make -j4
outfile=$2
>$outfile
cat $1 | while read line
do
    ./casexec $line | tee -a  $outfile
done

