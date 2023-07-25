# Instructions for running Polar Genomics Workshop Pipeline on your own system

### Install requirements / configure environment

```bash
# create 2 conda images because hyphy doesnt work when other packages installed
# first create a single hyphy image
conda create --name hyphy -y python=3.7
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda activate hyphy
conda install -y hyphy
conda deactivate

# next create an image for all othe programs
conda create --name polar -y python=3.7
conda activate polar

# note: the following command will take a while
conda install -y -c bioconda perl-uri perl-db-file orthofinder transdecoder pal2nal paml
conda install -y -c conda-forge r-ape
cpan URI::Escape Math::CDF JSON::Parse
pip install phylopypruner   
```
install <a href="https://github.com/josephryan/JFR-PerlModules">https://github.com/josephryan/JFR-PerlModules</a>

### Install utility scripts

```bash
# clone this repository
git clone https://github.com/josephryan/tmppolar

# install scripts
cd tmppolar/01-SCRIPTS
perl Makefile.pl 
make
make install
```

### Install SwissProt Database

```bash
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gzip -d uniprot_sprot.fasta.gz
diamond makedb uniprot_sprot.fasta
```
you will need to adjust the line diamond commands in the pipeline to point to the full path of this database `uniprot_sprot.fasta` rather than `/usr/local/uniprot/swissprot`.


### Install PFAM Database (optional)

For more accurate predictions with TransDecoder, it is recommended to use the hmmscan program from the HMMer package to identify domains in translated sequence that can be used by TransDecoder.predict to more accurately predict ORFS. Here is how to install hmmer.

```bash
conda install -c bioconda hmmer
```

Here's how to download the PFAM database

```bash
wget http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
gzip -d Pfam-A.hmm.gz
```

Here's the command to run hmmscan (this would be step 2b in the pipeline):

``bash
hmmscan --cpu 18 --domtblout Species_A.domtblout Pfam-A.hmm Species_A.fasta.transdecoder_dir/longest_orfs.pep > Sp_A.hmmscan.out 2> Sp_A.hmmscan.err
```

Here's the adjusted TransDecoder.Predict command (step 3 in the pipeline):

```bash
TransDecoder.Predict -t ../00-DATA/Species_A.fasta --retain_pfam_hits Species_A.domtblout --retain_blastp_hits Sp_A.diamond.out --cpu 18 > Sp_A.td.p.out 2> Sp_A.td.p.err &
```


