# Polar Genomics Workshop Pipeline

Each occurrence of "GATORLINK" below should be replaced with your GATORLINK username. 

### SETUP

Log into your nzinga account:
 
```bash
ssh GATORLINK@IPADDRESS
```

Activate the workshop conda image (this needs to be done with each new login)

```bash
conda activate /data1/conda/polar
```

<table bgcolor=grey border=1><tr><td><b>SCREEN</b>
Before running long-running processes, run the following: 

```bash
screen -S NAME_OF_SCREEN

# you need to activate conda env within screen
conda activate /data1/conda/polar
```


To detach from a screen session type the following:
 
```bash
Ctrl+a d      OR     screen -d
```

Make sure to reactivate conda environment after runnings screen
 
For info on using screen: <a href="https://linuxize.com/post/how-to-use-linux-screen/">https://linuxize.com/post/how-to-use-linux-screen/</a>

We mention where it's important to use screen below
</td></tr></table>

### Data

Each of you have this folder (actually a link to a read-only folder) in your main working directory:
 
```bash
/data1/GATORLINK/00-DATA
```

The folder contains the following sequence files:

```bash
Species_A.fasta
Species_B.fasta
Species_C.fasta
Species_D.fasta
Species_E.fasta
Species_F.fasta
Species_H.fasta
```

<table bgcolor=grey border=1><tr><td>
<b>TRINITY</b>

Assembling RNA-Seq data with Trinity is beyond the scope of this workshop. There is an excellent YouTube Video explaining details of Trinity algorithms from the author here: <a href="https://www.youtube.com/watch?v=NLzqvRo2qZs">https://www.youtube.com/watch?v=NLzqvRo2qZs</a>

Here is a step-by-step tutorial: <a href="https://github.com/trinityrnaseq/KrumlovTrinityWorkshopJan2020">https://github.com/trinityrnaseq/KrumlovTrinityWorkshopJan2020</a>
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
# note: the & at the end of the command will run the process in the
#       background allowing you to run all of them at once
TransDecoder.LongOrfs -t ../00-DATA/Species_B.fasta >tdB.out 2>tdB.err &
TransDecoder.LongOrfs -t ../00-DATA/Species_C.fasta >tdC.out 2>tdC.err &
TransDecoder.LongOrfs -t ../00-DATA/Species_D.fasta >tdD.out 2>tdD.err &
TransDecoder.LongOrfs -t ../00-DATA/Species_E.fasta >tdE.out 2>tdE.err &
TransDecoder.LongOrfs -t ../00-DATA/Species_F.fasta >tdF.out 2>tdF.err &
TransDecoder.LongOrfs -t ../00-DATA/Species_H.fasta >tdH.out 2>tdH.err &
```

##### This will create directories  “Species_A.fasta.transdecoder_dir” which contain:

```bash
base_freqs.dat
base_freqs.dat.ok
longest_orfs.cds
longest_orfs.gff3
longest_orfs.pep
```

##### Step 2a: Diamond (< 1 minute)

We use diamond (a fast BLAST replacement) to identify translated sequences that have similarity to the swissprot database. The resulting reports will be used by TransDecoder.predict to more accurately predict ORFS

```bash
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_A.fasta.transdecoder_dir/longest_orfs.pep  > Sp_A.diamond.out 2> Sp_A.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_B.fasta.transdecoder_dir/longest_orfs.pep  > Sp_B.diamond.out 2> Sp_B.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_C.fasta.transdecoder_dir/longest_orfs.pep  > Sp_C.diamond.out 2> Sp_C.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_D.fasta.transdecoder_dir/longest_orfs.pep  > Sp_D.diamond.out 2> Sp_D.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_E.fasta.transdecoder_dir/longest_orfs.pep  > Sp_E.diamond.out 2> Sp_E.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_F.fasta.transdecoder_dir/longest_orfs.pep  > Sp_F.diamond.out 2> Sp_F.diamond.err &
diamond blastp -p 3 -e 1e-5 -d /usr/local/uniprot/swissprot -q Species_H.fasta.transdecoder_dir/longest_orfs.pep  > Sp_H.diamond.out 2> Sp_H.diamond.err &
```

##### Step 3: predict the likely coding regions (>5 minutes)

```bash
TransDecoder.Predict -t ../00-DATA/Species_A.fasta --retain_blastp_hits Sp_A.diamond.out --cpu 18 > Sp_A.td.p.out 2> Sp_A.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_B.fasta --retain_blastp_hits Sp_B.diamond.out --cpu 18 > Sp_B.td.p.out 2> Sp_B.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_C.fasta --retain_blastp_hits Sp_C.diamond.out --cpu 18 > Sp_C.td.p.out 2> Sp_C.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_D.fasta --retain_blastp_hits Sp_D.diamond.out --cpu 18 > Sp_D.td.p.out 2> Sp_D.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_E.fasta --retain_blastp_hits Sp_E.diamond.out --cpu 18 > Sp_E.td.p.out 2> Sp_E.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_F.fasta --retain_blastp_hits Sp_F.diamond.out --cpu 18 > Sp_F.td.p.out 2> Sp_F.td.p.err &
TransDecoder.Predict -t ../00-DATA/Species_H.fasta --retain_blastp_hits Sp_H.diamond.out --cpu 18 > Sp_H.td.p.out 2> Sp_H.td.p.err &
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

<table bgcolor=grey border=1><tr><td>
<b>OrthoFinder</b>
<br>OrthoFinder is a fast, accurate and comprehensive platform for comparative genomics. It finds orthogroups and orthologs, infers rooted gene trees for all orthogroups and identifies all of the gene duplication events in those gene trees. It also infers a rooted species tree for the species being analyzed and maps the gene duplication events from the gene trees to branches in the species tree. OrthoFinder also provides comprehensive statistics for comparative genomic analyses. OrthoFinder is simple to use and all you need to run it is a set of protein sequence files (one per species) in FASTA format.

For more details see the OrthoFinder papers below.
<br>Emms, D.M. and Kelly, S. (2019) OrthoFinder: phylogenetic orthology inference for comparative genomics. <i>Genome Biology</i> 20:238
<br>Emms, D.M. and Kelly, S. (2015) OrthoFinder: solving fundamental biases in whole genome comparisons dramatically improves orthogroup inference accuracy. <i>Genome Biology</i> 16:157
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

##### Run Orthofinder (~30 minutes; run in the background and we'll break for lunch.) 

```bash
# MAY WANT TO INVOKE SCREEN HERE
# screen -S orthofinder
# conda activate /data1/conda/polar

orthofinder -X -z -t 18 -f 01-AA -M msa > of.out 2> of.err &

# detach from screen
screen -d
```

## BREAK FOR LUNCH

<table bgcolor=grey border=1><tr><td>
<b>Adding and/or subtracting species from an orthofinder analysis</b>

Often after running a large orthofinder analysis, you may need to add or subtract species from your study. For large studies, it can take a long time to start over. Orthofinder allows you to add and/or subtract species from an analysis. See the documentation.
</td></tr></table>

##### Orthofinder output

Orthofinder output should be here (e.g., Results_MonDD = Results_Jul24):   
<br>NOTE: you will need to replace "Results_MonDD" with the actual directory name in commands below

```bash
/data1/GATORLINK/02-ORTHOFINDER/01-AA/OrthoFinder/Results_MonDD
```

View overall stats:

```bash
cd /data1/GATORLINK/02-ORTHOFINDER/01-AA/OrthoFinder/Results_MonDD
```

```bash
less Comparative_Genomics_Statistics/Statistics_Overall.tsv
   # to exit less, type 'q'
```

Other potentially interesting OrthoFinder output files:

```bash
less ./Orthogroups/Orthogroups.tsv
less ./Orthogroups/Orthogroups_UnassignedGenes.tsv
less ./Orthogroups/Orthogroups.GeneCount.tsv
less ./Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv
less ./Comparative_Genomics_Statistics/Statistics_Overall.tsv
less ./Comparative_Genomics_Statistics/Orthogroups_SpeciesOverlaps.tsv
less ./Comparative_Genomics_Statistics/OrthologuesStats_Totals.tsv
less ./Comparative_Genomics_Statistics/OrthologuesStats_one-to-one.tsv
less ./Comparative_Genomics_Statistics/OrthologuesStats_one-to-many.tsv
less ./Comparative_Genomics_Statistics/OrthologuesStats_many-to-one.tsv
less ./Comparative_Genomics_Statistics/OrthologuesStats_many-to-many.tsv
less ./Comparative_Genomics_Statistics/Duplications_per_Species_Tree_Node.tsv
less ./Comparative_Genomics_Statistics/Duplications_per_Orthogroup.tsv
less ./Gene_Duplication_Events/Duplications.tsv
```

##### Gathering the datasets and trees that contain all seven species
 
We will use the `get_fasta_and_tree_w_min_number.pl` script to copy the alignments and corresponding gene trees that include all 7 species into a new folder that we name `02-GFWMN`. The script takes 4 arguments: (1) FASTA directory, (2) Gene_Trees directory, (3) output directory, and (4) the minimum number of species in the alignment.
 
```bash
cd /data1/GATORLINK/02-ORTHOFINDER

get_fasta_and_tree_w_min_number.pl --fa_dir=01-AA/OrthoFinder/Results_MonDD/MultipleSequenceAlignments --tree_dir=01-AA/OrthoFinder/Results_MonDD/Gene_Trees --out_dir=02-GFWMN --min_taxa=7

# we will use the output in 02-GFWMN for downstream analyses
```

##### PHYLOPYPRUNER

<table bgcolor=grey border=1><tr><td>
<b>PhyloPyPruner</b> - Pruning paralogous genes from each orthogroup

Orthologs are genes related through a speciation event, while paralogs are genes related through a gene duplication event. Paralogs create a challenge for phylogenomics since only a single gene can be represented in most phylogenomic analyses. 

PhyloPyPruner is a Python package for phylogenetic tree-based orthology inference, using the species overlap method. It uses trees and alignments inferred from the output of a graph-based orthology inference approach, such as <a href="https://www.ncbi.nlm.nih.gov/pubmed/12952885">OrthoMCL</a>, <a href="https://www.ncbi.nlm.nih.gov/pubmed/26243257">OrthoFinder</a> or <a href="https://www.ncbi.nlm.nih.gov/pubmed/19586527">HaMStR</a>, in order to obtain sets of sequences that are 1:1 orthologous. In addition to algorithms seen in pre-existing tree-based tools (for example, <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3825643/">PhyloTreePruner</a>, <a href="https://academic.oup.com/mbe/article/33/8/2117/2578877">UPhO</a>, <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3840672/">Agalma</a>, or <a href="https://www.ncbi.nlm.nih.gov/pubmed/25158799">Phylogenomic Dataset Reconstruction</a>), this package provides new methods for reducing potential contamination.

<a href="https://pypi.org/project/phylopypruner/">https://pypi.org/project/phylopypruner/</a>
</td></tr></table>

##### Run PhyloPyPruner (identify 1-to-1 orthologs)

```bash
mkdir /data1/GATORLINK/03-PHYLOPYPRUNER
cd /data1/GATORLINK/03-PHYLOPYPRUNER

phylopypruner --threads 18 --output . --dir ../02-ORTHOFINDER/02-GFWMN --mask longest --min-support 0.5 --min-taxa 7 --prune MI > pp.out 2> pp.err
```

Pruned alignments are created in this directory:

```bash
/data1/GATORLINK/03-PHYLOPYPRUNER/phylopypruner_output/output_alignments
```

##### Run PAL2NAL (align cds based on aa alignment)

Create a new directory and copy pruned alignments to this directory

```bash
mkdir /data1/GATORLINK/04-PAL2NAL

cd /data1/GATORLINK/04-PAL2NAL

# phylopypruner alignments sometimes have no residues and fewer than 7 seqs
# this may no longer be the case in the current version of phylopypruner in which case you could use `cp -R ../03-PHYLOPYPRUNER/phylopypruner_output/output_alignments 01-SEQS` instead
remove_blank_seqs_and_fewer_than_n.pl --out_dir=01-SEQS --min_seq=7  --aln_dir=../03-PHYLOPYPRUNER/phylopypruner_output/output_alignments 
```

Get CDS files that correspond with each of the pruned AA files

```bash
get_corresponding_cds.pl --cds_dir=../01-TRANSDECODER --aa_dir=01-SEQS --out_dir=02-CDS
```
  
Adjust names of sequences to only include species names.

```bash
perl -pi -e 's/^>([^|]+)\|.*/>$1/' 01-SEQS/* 02-CDS/*
```

Run pal2nal on the sequences in the cds and aa directories: 

```bash
run_pal2nal_on_cds_and_aa_dirs.pl --aa_dir=01-SEQS --cds_dir=02-CDS --outdir=03-P2N
```

Unroot Orthofinder species tree in R

```bash
mkdir /data1/GATORLINK/04-PAL2NAL/04-TREE
cd /data1/GATORLINK/04-PAL2NAL/04-TREE

cp ../../02-ORTHOFINDER/01-AA/OrthoFinder/Results_MonDD/Species_Tree/SpeciesTree_rooted.txt rooted.tree
```

Now run R

```bash
R
```

From within R run the following:

```R
library(ape)
tr <- read.tree("rooted.tree")
unrooted <- unroot(tr)
write.tree(unrooted, "unrooted.tree")
q()
```

Edit species name in the unrooted tree

```bash
# Before
cat unrooted.tree

perl -pi -e 's/.fasta.transdecoder//g' unrooted.tree

# After
cat unrooted.tree
```

##### PAML

```bash
mkdir -p /data1/GATORLINK/05-PAML

cd /data1/GATORLINK/05-PAML
```

Copy unrooted tree for PAML

```bash
cp ../04-PAL2NAL/04-TREE/unrooted.tree .
```

Annotate PAML tree ('unrooted.tree') by adding #1 after species name on foreground branches; branches A,B,C,D.

```bash
# Before
cat unrooted.tree

perl -pi -e 's/(Species_[ABCD])/$1#1/g' unrooted.tree

# After
cat unrooted.tree
```

Create symbolic links to the Pal2Nal alignments in the 05-PAML directory

```bash
ln -s ../04-PAL2NAL/03-P2N/*.phy .
```

Run CODEML (program within PAML that tests for selection; estimated time = 2+ hours?)

```bash
# MAY WANT TO INVOKE SCREEN HERE
# screen -S paml
# conda activate /data1/conda/polar

run_codeml.pl --tree=unrooted.tree --null --alt --aln_suf=phy > rc.out 2> rc.err &

# check progress
tail -f rc.out
# [CONTROL]+c   (to exit)
 
# detach from screen
# screen -d
```
 
##### HYPHY (make sure conda polar environment is activated)

```bash
mkdir -p /data1/GATORLINK/06-HYPHY/01-ALN

cd /data1/GATORLINK/06-HYPHY
```

Annotate HYPHY tree ('unrooted.tree') by adding {Foreground} after species name on foreground branches for tree file; branches A,B,C,D. 
 
```bash
cp ../04-PAL2NAL/04-TREE/unrooted.tree .

perl -pi -e 's/(Species_[ABCD])/$1\{Foreground\}/g' unrooted.tree
```

Copy aligned CDS files from PAL2NAL run:

```bash
cp ../04-PAL2NAL/03-P2N/*.fa_align.fa 01-ALN/

# NOTE: some alignments have fewer than 7
# NOTE: some alignments have no sequence data
# NOTE: only those alignments with sequences from 7 taxa will work unless tree is pruned
```

WORKAROUND FOR HYPHY

```bash
conda deactivate
conda activate /data1/conda/hyphy
```

Run a single BUSTED

```bash
hyphy busted --alignment 01-ALN/OGXXXXXXXXX_pruned.cds.fa_align.fa --tree unrooted.tree --branches Foreground --output OGXXXXXX.busted.json
```

Run a single aBSREL (adjust OGXXXXXXXXX to correspond with real file)

```bash
hyphy aBSREL --alignment 01-ALN/OGXXXXXXXXX_pruned.cds.fa_align.fa --tree unrooted.tree --branches Foreground --output OGXXXXXXXXX.absrel.json
```

Run a single MEME (adjust OGXXXXXXXXX to correspond with real file)

```bash
hyphy meme --alignment 01-ALN/OGXXXXXXXXX_pruned.cds.fa_align.fa --tree unrooted.tree --branches Foreground --output OGXXXXXXXXX.meme.json
```

Run a single RELAX (note: RELAX use --test instead of --branches to specify branches)  (adjust OGXXXXXXXXX to correspond with real file)

```bash
hyphy relax --alignment 01-ALN/OGXXXXXXXXX_pruned.cds.fa_align.fa --tree unrooted.tree --test Foreground --output OGXXXXXXXXX.relax.json
```

Run Busted, Absrel, and Meme (meme=7 hrs; busted=13 hrs; absrel=9 hrs):

```bash
# probably want to run screen here
screen -S hyphy
conda activate /data1/conda/polar

run_hyphy.pl --absrel --busted --meme --aln_dir=01-ALN --out_dir=02-OUT --tree=unrooted.tree --pre=hyphy --require_num_seqs=7 &

# detach from screen
screen -d
``` 

##### Parsing results
 
PAML ALT versus NULL models
 
Once complete you will have two CODEML MCL Results files for each of your CDS gene alignments (ALT versus NULL). Using the codeml_chisquare.pl you can generate p-values. The script calculates the cumulative probability of the chi-square distribution, given the degrees of freedom (DF = number of sequences) and the chi-square test statistic (`X`) which is: 2*(lnL1(ALT)-lnL0(NULL)). The p-value is then computed as 1 - chisqrprob(DF, X).

NOTE: --df (degrees of freedom) = the number of parameters in the alternative model minus the number of parameters in the null model). 

NOTE: --max_pval limits the output to those results with p-value less than the value supplied
 
```bash
mkdir /data1/GATORLINK/07-STATS
cd /data1/GATORLINK/07-STATS

codeml_chisquare.pl --codeml_dir=../05-PAML --alt_suf=alt.codeml --null_suf=null.codeml --df=1 --max_pval=0.05

```

##### IDENTIFY aBSREL outputs with positive test results

```bash
cd /data1/GATOR_LINK/06-HYPHY/02-OUT/hyphy.absrel
grep "corrected _p" *.out  | grep -v '\*\*0\*\*'
```


```bash
# this doesn't work yet
#parse_absrel.pl  --absrel_dir=../06-HYPHY/02-OUT/hyphy.absrel --suf=absrel.json > parse_absrel.out 2> parse_absrel.err

# parse_absrel.out will list files with positive results
# parse_absrel.err will list any errors including unparseable files
```

absrel.json outputs can be viewed here: http://vision.hyphy.org/absrel (click "Load" button in top right corner and upload file).

##### IDENTITY OF SIGNIFICANT GENES

You will need to identify the resulting significant candidate genes under positive selection. If you are familiar with batch BLAST searches, use what you like but I suggest making a batch query file from a representative peptide sequence from each of your peptide alignment files. Again, there are many ways to do this, but one example is listed below.
 
Extract the first sequence from each peptide alignment file.
 
```bash
for file in *.pep.fa; do awk '/^>/{if(N)exit;++N;} {print;}' $file > "$(basename "$file" .tex)_seq1.fasta"; done
```
 
Then you can cat all of those sequences with their alignment IDs into one fasta file.
 
```bash
cat *._seq1.fasta > candidategenes.fasta
 
blastp -query candidategenes.fasta -num_threads 8 -outfmt '6 qseqid sseqid pident length evalue bitscore staxids sscinames scomnames sskingdoms stitle' -max_target_seqs 1 -seg yes -evalue 0.001 -db nr -out Candidategenes_blastp 2> Candidategenes.err
```
 
NOTE: You may want to make your own blastp reference database of a subset of relevant sequences or use the entire blastp database if you have everything already installed on a local machine. Obviously you can adjust many options in the above search, particularly the number of maximum target sequences/evalue for genes with ambiguous identitities.
 
```bash
makeblastdb -dbtype prot -in Relevant.fasta -out RelevantDBseqs.fasta
```
 
##### HYPHY JSON File Parsing
 
Results will be found in OG0008203.BUSTED.json. You can quickly assess whether the test was significant or not by using grep.
 
```bash
grep p-value *.busted.out > busted_results.txt
```
 
"p-value":1.269001392856239e-08
 
The results may also be parsed using Hyphy-Vision (http://vision.hyphy.org)
 
```bash
grep '"Corrected P-value":' *.ABSREL.json > ABS_pvalues.txt
```
 
Meme Parsing?: <a href="https://github.com/sjspielman/phyphy">https://github.com/sjspielman/phyphy</a>
 
END DAY One of Workshop.
 
##### References

Benjamini Y. 2010. Discovering the false discovery rate. <i>Journal of the Royal Statistical Society: Series B (Statistical Methodology)</i> 72:405–416.

Bielawski JP, Baker JL, Mingrone J. 2016. Inference of Episodic Changes in Natural Selection Acting on Protein Coding Sequences via CODEML. <i>Current Protocols in Bioinformatics</i> 54:6.15.1–6.15.32.

Gharib WH, Robinson-Rechavi M. 2013. The branch-site test of positive selection is surprisingly robust but lacks power under synonymous substitution saturation and variation in GC. <i>Molecular Biology and Evolution</i> 30:1675–1686.

Murrell B, Weaver S, Smith MD, Wertheim JO, Murrell S, Aylward A, Eren K, Pollner T, Martin DP, Smith DM, Scheffler K, Kosakovsky Pond SL. 2015. Gene-Wide Identification of Episodic Selection. <i>Molecular Biology and Evolution</i> 32:1365–1371.

Murrell B, Wertheim JO, Moola S, Weighill T, Scheffler K, Kosakovsky Pond SL. 2012. Detecting Individual Sites Subject to Episodic Diversifying Selection. <i>PLoS Genetics</i> 8:1-10.

Smith MD, Wertheim JO, Weaver S, Murrell B, Scheffler K, Kosakovsky Pond SL. 2015. Less Is More: An Adaptive Branch-Site Random Effects Model for Efficient Detection of Episodic Diversifying Selection. <i>Molecular Biology and Evolution</i> 32:1342–1353.

Stamatakis A. 2014. RAxML version 8: a tool for phylogenetic analysis and post-analysis of large phylogenies. <i>Bioinformatics</i> 30:1312–1313.

Steinegger M, Meier M, Mirdita M, Vöhringer H, Haunsberger SJ, Söding J. 2019. HH-suite3 for fast remote homology detection and deep protein annotation. <i>BMC Bioinformatics</i> 20:1–15.

Suyama M, Torrents D, Bork P. 2006. PAL2NAL: robust conversion of protein sequence alignments into the corresponding codon alignments. <i>Nucleic Acids Research</i> 34:W609–12.

Thomas PD, Campbell MJ, Kejariwal A, Mi H, Karlak B, Daverman R, Diemer K, Muruganujan A, Narechania A. 2003. PANTHER: A Library of Protein Families and Subfamilies Indexed by Function. <i>Genome Research</i> 13:2129–2141.

Yang Z, Nielsen R, Goldman N, Pedersen AM. 2000. Codon-substitution models for heterogeneous selection pressure at amino acid sites. <i>Genetics</i> 155:431–449.

Yang Z, Reis dos M. 2011. Statistical Properties of the Branch-Site Test of Positive Selection. <i>Molecular Biology and Evolution</i> 28:1217–1228.

Yang Z, Wong WSW, Nielsen R. 2005. Bayes empirical bayes inference of amino acid sites under positive selection. <i>Molecular Biology and Evolution</i> 22:1107–1118.

Zhang J. 2005. Evaluation of an Improved Branch-Site Likelihood Method for Detecting Positive Selection at the Molecular Level. <i>Molecular Biology and Evolution</i> 22:2472–2479.

