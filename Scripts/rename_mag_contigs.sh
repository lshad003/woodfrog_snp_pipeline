#!/usr/bin/bash -l
#SBATCH -p short

for a in $(cat MAGs.fofn)
do
        n=$(basename $a .fa)
        perl -p -e "s/>/>$n./" $a
done > db/all_mags.fa
