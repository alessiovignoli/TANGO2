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
or with no contenairization technology, not advisable since `t_coffe` has to be already installed in the system and callable as command, read >Pipeline description<:
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
