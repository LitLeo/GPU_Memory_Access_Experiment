#!/bin/bash
make -j4
outfile='out.txt'
>$outfile
cat $1 | while read line
do
    ./casexec $line | tee -a  $outfile
done

