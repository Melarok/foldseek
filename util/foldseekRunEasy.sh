#! /bin/bash

for query in /mnt/query/*.pdb; do
    qName=$(basename "$query" .pdb)
    mkdir -p /mnt/results/"$qName"
    for db in /mnt/db/*.DB; do
        dName=$(basename "$db" .DB)
        echo -e "\nProcessing query $qName on database $dName"
        /usr/local/bin/foldseek_avx2 easy-search "$query" "$db" /mnt/results/"$qName"/"$qName"-"$dName".html /tmp --threads 16 -v 1 --format-mode 3 -e 0.005
    done
done