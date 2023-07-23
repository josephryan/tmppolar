# Instructions for running Polar Genomics Workshop Pipeline on your own system

### Install requirements / configure environment

```bash
conda create --name polar -y python=3.7
conda activate polar

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

conda install -y -c bioconda perl-uri perl-db-file orthofinder transdecoder pal2nal hyphy paml
conda install -y -c conda-forge r-ape
cpan URI::Escape Statistics::Distributions
pip install phylopypruner   
```

install <a href="http://abacus.gene.ucl.ac.uk/software/">PAML</a>

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

