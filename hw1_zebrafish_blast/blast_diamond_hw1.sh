#!/bin/bash
set -e

module load BLAST+
module load DIAMOND

if [ ! -f zebrafish.1.protein.faa ]; then
  curl -o zebrafish.1.protein.faa.gz -L https://osf.io/68mgf/download
  gunzip -f zebrafish.1.protein.faa.gz
fi

if [ ! -f mgProteome.fasta ]; then
  cp /work/pbgg8900/instructor_data/mgProteome.fasta .
fi

if [ ! -f zebrafish_protein_db.pin ]; then
  makeblastdb -in zebrafish.1.protein.faa -dbtype prot -out zebrafish_protein_db
fi

blastp \
  -query mgProteome.fasta \
  -db zebrafish_protein_db \
  -out mg_vs_zebrafish.blastp.out \
  -evalue 1e-5 \
  -outfmt 6

if [ ! -f zebrafish_protein_db.dmnd ]; then
  diamond makedb --in zebrafish.1.protein.faa --db zebrafish_protein_db
fi

diamond blastp \
  --query mgProteome.fasta \
  --db zebrafish_protein_db.dmnd \
  --out mg_vs_zebrafish.diamond.out \
  --evalue 1e-5 \
  --outfmt 6 \
  --threads 4
