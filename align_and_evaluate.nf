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
        log.info ""
        log.info ""
        log.info ""
        log.info ""
        log.info ""
        log.info ""
        log.info ""
        log.info ""
        log.info "" 
}

params.CONTAINER = "cbcrg/tcoffee@sha256:36c526915a898d5c15ede89bbc3854c0a66cef22db86285c244b89cad40fb855" // tcoffee version 
params.IN = false
params.OUT_DIR = "${launchDir}/results/"



process align_generation {
	container params.CONTAINER
        publishDir(params.OUT_DIR, mode: 'move', overwrite: false)
        tag { "${multifasta}" }

        input:
        path multifasta

        output:
        path tcoffee_outfilepath, emit: aln_file

        script:
        tcoffee_outfilepath = "${multifasta}".split('\\.')[0] + '.aln'
        """
        t_coffee -in ${multifasta} -outfile ${tcoffee_outfilepath}
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

	emit:
	stout = align_generation.out.aln_file
}


workflow {
	tcoffee_evaluate_msas(params.IN)
	tcoffee_evaluate_msas.out.stout.view()
}
