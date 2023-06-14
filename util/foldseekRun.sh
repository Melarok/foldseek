#! /bin/bash

for query in /mnt/query/*.pdb; do
    for db in /mnt/db/*.DB; do
        echo "Processing query $(basename "$query") on database $(basename "$db")"
        /usr/local/bin/foldseek_avx2 easy-search "$query" "$db" /mnt/results/"$query"-"$db" /tmp --threads 16 -v 1
    done
done