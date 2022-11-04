#!/usr/bin/env nextflow



// this prints the help in case you use --help parameter in the command line and it stops the pipeline
if (params.help) {
        log.info "This pipeline accepts one or more input fasta files, it builds a Multiple Sequence Alignment (MSA) for each input file"
	log.info "and it reports average % identity and tcoffee built in quality asci-score for each MSA."
	log.info ""
        log.info "Here is the list of flags accepted by the pipeline:"
	log.info "--IN		a glob path to the input fasta files. For example in1.fa, in2.fa and in3.fa are the inputs files"
        log.info "		they are present in the directory /home/Desktop/fastas/, in this case the command line would need this:"
        log.info '		--IN "/home/Desktop/fastas/in*.fa"  or "/home/Desktop/fastas/*"  if those are the only files in the directory.'
        log.info "		This argument also accepts relative glob paths, keep in mind that the path has to be ralative to where the "
        log.info "		pipeline has been launched."
        log.info "--OUT_DIR	optional flag, it tells the script where to put the output files, default ${launchDir}/results/."
        log.info "		Where launchDir variable is the directory where the pipeline has been launched fron."
        log.info "		If the directory does not exist it will be created automatically."
        log.info ""
        log.info "The output of the pipelines are <input_filename>.score_ascii files reporting the MSA and the built in t-coffee score ascii"
        log.info "plus a results.scores file reporting what is printed to standard output at the end of the pipeline."
        log.info "This file is the result of the     t_coffee -other_pg aln_compare     command."
        log.info "first column is the file name, second column is the number of sequnces in the MSA, third the average percentage Identity"
        log.info "between the sequences, fourth is irrelevant, fifth id the number of columns in th MSA."
        log.info ""
        log.info ""
        log.info ""
        log.info "" 
}

params.CONTAINER = "cbcrg/tcoffee@sha256:36c526915a898d5c15ede89bbc3854c0a66cef22db86285c244b89cad40fb855" // tcoffee Version_13.45.47.aba98c5
params.IN = false
params.OUT_DIR = "${launchDir}/results/"



process align_generation {
	container params.CONTAINER
	label 'incr_time_cpus'
        tag { "${multifasta}" }

        input:
        path multifasta

        output:
        path tcoffee_outfilepath, emit: aln_file

        script:
        tcoffee_outfilepath = "${multifasta}".split('\\.')[0] + '.aln'
        """
        t_coffee -in ${multifasta} -mode=regular -outfile ${tcoffee_outfilepath} -maxnseq=150 -maxlen=10000 -case=upper -seqnos=off -outorder=input -run_name=result -multi_core=${task.cpus}
        """
}


process tcoffee_scores_production {
	container params.CONTAINER
        publishDir(params.OUT_DIR, mode: 'move', overwrite: false)
        tag { "${in_aln}" }
	
	input:
        path in_aln

	output:
        stdout emit: standardout
	path ascii_scorefile, emit: ascii_score
	
	script:
	ascii_scorefile = "${in_aln.baseName}.score_html"
	"""
	t_coffee -other_pg seq_reformat -in ${in_aln} -action +evaluate blosum62mt -output score_html > ${ascii_scorefile}
	t_coffee -other_pg aln_compare -al1 ${in_aln} -al2 ${in_aln} -compare_mode sp
	echo Coverage
	t_coffee -other_pg seq_reformat -in ${in_aln} -output cov | tail -n 4 | awk  '{print \$2, \$4}'
	"""
}



workflow tcoffee_evaluate_msas {

	take:
	pattern_to_in
	
	main:
	
	// error section

	if ( !pattern_to_in ) {
                log.info "ERROR: no valid input given, pass --IN argument from command line or type --help for description of pipeline"
                exit 1
        }

	// Actual pipeline section, extracting species names and fastaID as well asmatching with input fasta filenames

	in_files = Channel.fromPath(pattern_to_in)
	align_generation(in_files)
	tcoffee_scores_production(align_generation.out.aln_file)
	tcoffee_scores_production.out.standardout.collectFile(name: 'results.scores', storeDir: params.OUT_DIR)

	emit:
	stout = tcoffee_scores_production.out.standardout
}


workflow {
	tcoffee_evaluate_msas(params.IN)
	tcoffee_evaluate_msas.out.stout.view()
}
