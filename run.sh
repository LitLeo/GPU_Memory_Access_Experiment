#!/bin/bash
make -j4
outfile='out.txt'
>$out
cat params.txt | while read line
do
    ./casexec $line | tee $out
done

