#! /bin/bash

eVal=$1
threads=$2
aType=$3
formats=$4

formatOptions="query,target,evalue,gapopen,pident,fident,nident,qstart,qend,qlen,tstart,tend,tlen,alnlen,raw,bits,cigar,qseq,tseq,qheader,theader,qaln,taln,mismatch,qcov,tcov,qset,qsetid,tset,tsetid,taxid,taxname,taxlineage,lddt,lddtfull,qca,tca,t,u,qtmscore,ttmscore,alntmscore,rmsd,prob"

/usr/local/bin/foldseek_avx2 createdb /mnt/query/* querydb --threads "$threads" -v 1

resultFolder="/mnt/results/$(date -Iminutes)"
mkdir -p "$resultFolder"/raw "$resultFolder"/processed

for db in /mnt/db/*.DB; do
    dName=$(basename "$db" .DB)
    result="$resultFolder"/raw/"$(basename "$db")".res
    echo -e "\nProcessing querydb on targetdb $dName"
    
    /usr/local/bin/foldseek_avx2 search querydb "$db" "$result" /tmp --alignment-type "$aType" -e "$eVal" --threads "$threads" -v 1 -a
    

    if [[ $formats = *m8* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".m8 --threads "$threads" -v 1
    fi
    if [[ $formats = *html* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".html --format-mode 3 --threads "$threads" -v 1
    fi
    if [[ $formats = *sam* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".sam --format-mode 1 --threads "$threads" -v 1
    fi
    if [[ $formats = *pdb* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".pdb --format-mode 5 --threads "$threads" -v 1
    fi
    if [[ $formats = *tsv* ]]; then
        /usr/local/bin/foldseek_avx2 convertalis querydb "$db" "$result" "$resultFolder"/processed/"$dName".tsv --format-mode 4 --format-output $formatOptions --threads "$threads" -v 1
    fi
done
