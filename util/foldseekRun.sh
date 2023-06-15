#! /bin/bash

/usr/local/bin/foldseek_avx2 createdb /mnt/query/* querydb --threads 16 -v 1

results="/mnt/results/$(date -Iminutes)"
mkdir -p "$results"/raw "$results"/processed

for db in /mnt/db/*.DB; do
    dName=$(basename "$db" .DB)
    echo -e "\nProcessing querydb on targetdb $dName"
    /usr/local/bin/foldseek_avx2 search querydb "$db" "$results"/raw/"$dName".res /tmp -e 0.005 --threads 16 -v 1
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/raw/"$dName".res "$results"/processed/"$dName".m8 --threads 16 -v 1
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/raw/"$dName".res "$results"/processed/"$dName".html --format-mode 3 --threads 16 -v 1
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$results"/raw/"$dName".res "$results"/processed/"$dName".pdb --format-mode 5 --threads 16 -v 1
done
