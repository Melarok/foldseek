#! /bin/bash

eVal=$1
threads=$2
aType=$3
formats=$4

formatOptions="query,target,evalue,qlen,tlen,alnlen,mismatch,qcov,tcov,lddt,qtmscore,ttmscore,alntmscore,rmsd,tseq"
resultFolder="/mnt/results/foldseek_e$(echo $eVal)_$(date +'%Y-%m-%d_%H-%M-%S')/out"

mkdir -p "$resultFolder"/tmp

/usr/local/bin/foldseek_avx2 createdb /mnt/query/* querydb --threads "$threads" -v 1

for db in /mnt/db/*.DB; do
    dName=$(basename "$db" .DB)
    result="$resultFolder/tmp/$dName.res"
    echo -e "\nProcessing querydb on targetdb $dName"
    
    /usr/local/bin/foldseek_avx2 search querydb "$db" "$result" /tmp --alignment-type "$aType" -e "$eVal" --threads "$threads" -v 1 -a
    
    if [[ $formats = *m8* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/"$dName".m8 --threads "$threads" -v 1
    fi
    if [[ $formats = *html* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/"$dName".html --format-mode 3 --threads "$threads" -v 1
    fi
    if [[ $formats = *sam* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/"$dName".sam --format-mode 1 --threads "$threads" -v 1
    fi
    if [[ $formats = *pdb* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/"$dName".pdb --format-mode 5 --threads "$threads" -v 1
    fi
    if [[ $formats = *tsv* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/"$dName".tsv --format-mode 4 --format-output $formatOptions --threads "$threads" -v 1
    fi
done

rm -rf "$resultFolder"/tmp
