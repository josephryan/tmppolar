# Polar Genomics Workshop Pipeline

At the start, you may want to search and replace "GATORLINK" with your gatorlink.

### SETUP

Log into your nzinga account:
 
```bash
ssh GATORLINK@IPADDRESS
```

Activate the workshop conda image (this needs to be done with each new login)

```bash
conda activate /data1/jfryan2023/00-CONDA/polar
```

<table border=1><tr><td bgcolor="gray">SCREEN
<br>Before running long-running processes, run the following: 
<br>
<br>	screen -S NAME_OF_SCREEN
<br> 
<br>To detach from a screen session type the following:
<br> 
<br>	Ctrl+a d      OR     screen -d
<br>Make sure to reactivate conda environment after runnings screen
<br> 
<br>For info on using screen: https://linuxize.com/post/how-to-use-linux-screen/
<br>
<br>We mention where it's important to use screen below
</td></tr></table>

### Data

Each of you have this folder (actually a link to a read-only folder):
 
```/data1/GATORLINK/00-DATA
```

The folder contains the following sequence files:

```Species_A.fasta
Species_B.fasta
Species_C.fasta
Species_D.fasta
Species_E.fasta
Species_F.fasta
Species_H.fasta
```

<table border=1><tr><td bgcolor="gray">TRINITY
Assembling RNA-Seq data with Trinity is beyond the scope of this workshop. There is an excellent YouTube Video explaining details of Trinity algorithms from the author here:

    <a href="https://www.youtube.com/watch?v=NLzqvRo2qZs">https://www.youtube.com/watch?v=NLzqvRo2qZs</a>

Here is a step-by-step tutorial:

    <a href="https://github.com/trinityrnaseq/KrumlovTrinityWorkshopJan2020">https://github.com/trinityrnaseq/KrumlovTrinityWorkshopJan2020</a>
</td></tr></table>

### TransDecoder

We use TransDecoder to find long open reading frames within these transcripts (https://github.com/TransDecoder/TransDecoder/wiki)
TransDecoder identifies candidate coding regions within transcript sequences and determines which of these present likely coding sequences (see URL above for the criteria).
 
##### Step 1: Identify longest orfs. (2-3 minutes per FASTA)

```bash
mkdir /data1/GATORLINK/01-TRANSDECODER

cd /data1/GATORLINK/01-TRANSDECODER
```

##### Step 2: Identify longest orfs. (2-3 minutes per FASTA)
 
```bash
TransDecoder.LongOrfs -t ../00-DATA/Species_A.fasta >tdA.out 2>tdA.err

# run TransDecoder.LongOrfs on the rest of the fasta files (for B-H)
TransDecoder.LongOrfs -t ../00-DATA/Species_B.fasta >tdB.out 2>tdB.err
TransDecoder.LongOrfs -t ../00-DATA/Species_C.fasta >tdC.out 2>tdC.err
TransDecoder.LongOrfs -t ../00-DATA/Species_D.fasta >tdD.out 2>tdD.err
TransDecoder.LongOrfs -t ../00-DATA/Species_E.fasta >tdE.out 2>tdE.err
TransDecoder.LongOrfs -t ../00-DATA/Species_F.fasta >tdF.out 2>tdF.err
TransDecoder.LongOrfs -t ../00-DATA/Species_H.fasta >tdH.out 2>tdH.err
```

##### This will create directories  “Species_A.fasta.transdecoder_dir” which contain:

```base_freqs.dat
base_freqs.dat.ok
longest_orfs.cds
longest_orfs.gff3
longest_orfs.pep
```

##### Step 2a: Diamond (< 1 minute)

We use diamond (a fast BLAST replacement) to identify translated sequences that have similarity to the swissprot database. The resulting reports will be used by TransDecoder.predict to more accurately predict ORFS

```bash
diamond blastp -p 18 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_A.fasta.transdecoder_dir/longest_orfs.pep  > Sp_A.diamond.out 2> Sp_A.diamond.err

# run diamond on the rest of the longest_orfs.pep (for B-H)
```

##### Step 3: predict the likely coding regions (>5 minutes)

```bash
TransDecoder.Predict -t ../00-DATA/Species_A.fasta --retain_blastp_hits Sp_A.diamond.out --cpu 18 > Sp_A.td.p.out 2> Sp_A.td.p.err &

# run TransDecoder.Predict on the rest of the files in ../00-DATA (for B-H)
```

##### TransDecoder output

TransDecoder will generate several files in Species_A.fasta.transdecoder_dir/
and the following files in /data1/GATORLINK/01-TRANSDECODER
 
```bash
Species_A.fasta.transdecoder.bed
Species_A.fasta.transdecoder.cds #(used later in selection tests)
Species_A.fasta.transdecoder.gff3
Species_A.fasta.transdecoder.pep #(used in next step / orthofinder)
```

### Orthogroup Assignments

<table border=1><tr><td bgcolor="gray">OrthoFinder
OrthoFinder is a fast, accurate and comprehensive platform for comparative genomics. It finds orthogroups and orthologs, infers rooted gene trees for all orthogroups and identifies all of the gene duplication events in those gene trees. It also infers a rooted species tree for the species being analyzed and maps the gene duplication events from the gene trees to branches in the species tree. OrthoFinder also provides comprehensive statistics for comparative genomic analyses. OrthoFinder is simple to use and all you need to run it is a set of protein sequence files (one per species) in FASTA format.
For more details see the OrthoFinder papers below.
Emms, D.M. and Kelly, S. (2019) OrthoFinder: phylogenetic orthology inference for comparative genomics. Genome Biology 20:238
Emms, D.M. and Kelly, S. (2015) OrthoFinder: solving fundamental biases in whole genome comparisons dramatically improves orthogroup inference accuracy. Genome Biology 16:157
<br> 
HOMEPAGE: <a href="https://github.com/davidemms/OrthoFinder">https://github.com/davidemms/OrthoFinder</a>
</td></tr></table>

##### Create a directory of symbolic links to all of the protein datasets

```bash
mkdir -p /data1/GATORLINK/02-ORTHOFINDER/01-AA
cd /data1/GATORLINK/02-ORTHOFINDER/01-AA
ln -s ../../01-TRANSDECODER/*.transdecoder.pep .
cd ..
```

##### Run Orthofinder (~30 minutes; run in the background and we'll break for lunch) 

orthofinder -X -z -t 18 -f 01-AA -M msa > of.out 2> of.err &

## BREAK FOR LUNCH


