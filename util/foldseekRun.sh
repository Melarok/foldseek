#! /bin/bash

/usr/local/bin/foldseek_avx2 createdb /mnt/query/* querydb --threads 16 -v 1

resultFolder="/mnt/results/$(date -Iminutes)"
mkdir -p "$resultFolder"/raw "$resultFolder"/processed

for db in /mnt/db/*.DB; do
    dName=$(basename "$db" .DB)
    result="$resultFolder"/raw/"$(basename "$db")".res
    echo -e "\nProcessing querydb on targetdb $dName"
    /usr/local/bin/foldseek_avx2 search querydb "$db" "$result" /tmp -e 0.005 --threads 16 -v 1 -a
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".m8 --threads 16 -v 1
    /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".html --format-mode 3 --threads 16 -v 1
done
