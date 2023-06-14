#! /bin/bash

for query in /mnt/query/*.pdb; do
    qName=$(basename "$query" .pdb)
    for db in /mnt/db/*.DB; do
        dName=$(basename "$db" .DB)
        echo -e "\nProcessing query $qName on database $dName"
        /usr/local/bin/foldseek_avx2 easy-search "$query" "$db" /mnt/results/"$qName"-"$dName".html /tmp --threads 16 -v 1 --format-mode 3
    done
done