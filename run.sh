#!/bin/bash
make -j4
outfile='out.txt'
>$outfile
cat params.txt | while read line
do
    ./casexec $line | tee -a  $outfile
done

