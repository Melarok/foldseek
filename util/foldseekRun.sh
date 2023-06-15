#! /bin/bash

/usr/local/bin/foldseek_avx2 createdb /mnt/query/* querydb --threads 16

results="/mnt/results/$(date -Iminutes)"
mkdir -p "$results"

for db in /mnt/db/*.DB; do
    dName=$(basename "$db" .DB)
    echo -e "\nProcessing querydb on targetdb $dName"
    /usr/local/bin/foldseek_avx2 search querydb "$db" "$results"/"$dName" /tmp -e 0.005 --threads 16
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/"$dName" "$results"/"$dName".m8 --threads 16
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/"$dName" "$results"/"$dName".html --format-output 3 --threads 16
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/"$dName" "$results"/"$dName".pdb --format-output 5 --threads 16
done
