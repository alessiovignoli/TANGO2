## Repository used in analizing TANGO2 protetein family
### This code is free and open source

### Requirements

the bare minimun requirement is `nextflow DSL2`, simply  go to https://www.nextflow.io/ and follow the instruction for the installation.

It is advisable to couple a contanairization engine with `nextflow` for reproducibility porpuses. The ones supported  by this pipeline are `Docker` and `Singularity`.
Check their respective installation guides.


### Instalation

Simply instal git and laungh the following command:
```
git clone https://github.com/alessiovignoli/TANGO2/
```
or downloaded the whole directory manually, every file present in this repo with the exception of the `results/` subdir are necessary.


## Running the pipeline
### Run the provided example locally

Once you have he `TANGO2` directory downloaded move inside it with:
```
cd TANGO2
```
in here there is the main nextflow pipeline called `align_and_evaluate.nf` as well as the `nextflow.config` file. For this reason this is in all intents and porpuses where the pipeline should be launched from. To run the example pipeline just launch the following command :
```
nextflow run align_and_evaluate.nf --IN "data/*" -profile standard,docker
```
or using `singularity`:
```
nextflow run align_and_evaluate.nf --IN "data/*" -profile standard,singularity
```
or with no contenairization technology, not advisable since `t_coffe` has to be already installed in the system and callable as command, read  Pipeline description section for more details:
```
nextflow run align_and_evaluate.nf --IN "data/*" -profile standard
```
This is how the files present in the `results/` directory have been created in the first plsce. The above commands will not move the output file to the `results/` subdirectory since it sees that they are alredy there (In case they are not it will).
To print an help message explaining the available flags use the following command:
```
nextflow run align_and_evaluate.nf --help
```

### Run the provided example on cluster and cloud

Make sure to edit the `nextflow.config` file with your necessity, under the cluster profile before running the pipeline, mainly `process.executor` and `process.queue` since they vary across cluster. For more info take a look at nextflow documentation page https://www.nextflow.io/docs/latest/config.html# .

The command syntax is the following, keep in mind that `docker` profile name is interchangable with `singularity`:
```
nextflow run align_and_evaluate.nf --IN "data/*" -profile cluster,docker
```

as said for running on cluster, the `nextflow.config` file has to be changed to run on cloud environment. The lines of code present in the `cloud` scope are indicative and should be rewritten and modified by the user, refer to the manual page indicated above.
Having said that the command is the following:
```
nextflow run align_and_evaluate.nf --IN "data/*" -profile cloud,singularity
```


## Pipeline description

This pipeline expects one or more fasta files containg the sequences that have to be alligned. A Multiple Sequence Allignment (MSA) is produced for each fasta input; so be aware to put in the same file all the sequences you want to allign toghether. 
The allignment is computed using the following command (t_coffee version_13.45.47.aba98c5):
```
t_coffee -in input.fasta-mode=regular -outfile input.aln -maxnseq=150 -maxlen=10000 -case=upper -seqnos=off -outorder=input -run_name=result -multi_core=6
```
To see the exact nextflow adapted command just open the `align_and_evaluate.nf` file. 

Once the MSAs have been creted the pipeline computes for each of them the TCS (score_ascii), average percentage identity  and average coverage scores, using the following commands:
```
t_coffee -other_pg seq_reformat -in input.aln -action +evaluate blosum62mt -output score_ascii > input.score_ascii
t_coffee -other_pg aln_compare -al1 input.aln -al2 input.aln -compare_mode sp
t_coffee -other_pg seq_reformat -in input.aln -output cov 
```

To standard output is printed the result of the last comand reporting, filename, number of sequences, average % identity, 100% (similarity with itself) and number of columns in MSA. This is an example:
```
*****************************************************
seq1       seq2          Sim   [ALL]           Tot  
TANGO2_Q6ICL3-2 5          32.6   100.0 [100.0]   [ 4856]
```
The field described above are on the last row. For more detail on the `aln_compare` command take a look at https://tcoffee.readthedocs.io/en/latest/tcoffee_main_documentation.html#estimating-the-diversity-in-your-alignment . for each MSA on top of te above lines there are other five more stating the covariace values as depicted below:
```
Coverage
TOT 88.60
AVG 88.60
VAR 49.38
STD 7.03
```
The names are self explanatory.

Standard out inforamtion are also saved to `--OUT_DIR` option location in a file called results.scores.

The other type of output is the allignment reporing the TCS score in htnml format. This files are also present in the `--OUT_DIR` specified derectory (default `results/`) and an example is present in `results/` subfolder.

