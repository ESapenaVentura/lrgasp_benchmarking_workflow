#!/usr/bin/env nextflow

if (params.help) {
	
	    log.info"""
	    ==============================================
	    LRGASP CHALLENGE 1 EVALUATION BENCHMARKING PIPELINE
	    Author(s): Enrique Sapena Ventura
	    Barcelona Supercomputing Center. Spain. 2021
	    ==============================================
	    Usage:
	    Run the pipeline with default parameters:
	    nextflow run main.nf -profile docker

	    Run with user parameters:

 	    nextflow run main.nf -profile docker --input {driver.genes.file} --public_ref_dir {validation.reference.file} --participant_id {tool.name} --goldstandard_dir {gold.standards.dir} --cancer_types {analyzed.cancer.types} --assess_dir {benchmark.data.dir} --augmented_assess_dir {benchmark.augmented_data.dir} --results_dir {output.dir}

		For more informations on the parameters, please see the README.md file located in the dockers repository 'example_data' folder.
	    Mandatory arguments:
                --input                 Directory where the input files can be found
                --community_id          Name or OEB permanent ID for the benchmarking community
                --public_ref_dir        Directory with public reference genome and annotation files
                --participant_id        Name of the tool used for benchmarking
                --goldstandard_dir      Dir that contains metrics reference data for SIRVs
                --challenges_ids        List of challenges (iso_detect_ref_<sample>_<library_prep>_<sequencing_platform>_<read_length_used>) which are included in the benchmark. For a full list available, please see README.md
                --assess_dir            Dir where the input data for the benchmark are stored

	    Other options:
				--gtf_filename			Name of the GTF file with model annotations.
				--sj_filename			Name of the Splice Junction file created by STAR.
				--entry_json			Name of the entry.json file. If not provided, defaults to 'entry.json'
				--experiment_json		Name of the experiment.json file. If not provided, defaults to 'experiment.json'
				--read_model_map_filename	Name of the read to transcript model map file.
				--cage_peak_filename	Name of the CAGE-peak file.
				--polya_name			Name of the polyA motif list
				--ref_genome_filename	Name of the reference genome, with SIRV data
				--ref_transcriptome_filename	Name of the reference transcriptome, with SIRV data

                --validation_result     The output directory where the results from validation step will be saved
                --augmented_assess_dir  Dir where the augmented data for the benchmark are stored
                --assessment_results    The output directory where the results from the computed metrics step will be saved
                --outdir                The output directory where the consolidation of the benchmark will be saved
                --statsdir              The output directory with nextflow statistics
                --data_model_export_dir The output dir where json file with benchmarking data model contents will be saved
                --otherdir              The output directory where custom results will be saved (no directory inside)
	    Flags:
                --help                  Display this message
	    """

	exit 1
} else {

	log.info """\
         ==============================================
           LRGASP CHALLENGE 1 - ISOFORM QUANTIFICATION
         ==============================================
         input directory: ${params.input}
         benchmarking community = ${params.community_id}
         public reference directory : ${params.public_ref_dir}
         tool name : ${params.participant_id}
         metrics reference datasets: ${params.goldstandard_dir}
         selected challenges: ${params.challenges_ids}
         benchmark data: ${params.assess_dir}
         augmented benchmark data: ${params.augmented_assess_dir}
         validation results directory: ${params.validation_result}
         assessment results directory: ${params.assessment_results}
         consolidated benchmark results directory: ${params.outdir}
         Statistics results about nextflow run: ${params.statsdir}
         Benchmarking data model file location: ${params.data_model_export_dir}
         Directory with community-specific results: ${params.otherdir}
         """

}


// input files

input_dir = Channel.fromPath( params.input, type: 'dir' )
input_gtf = params.gtf_filename
input_cage_peak = params.cage_peak_filename
input_polyA = params.polya_name
entry_json = params.entry_json
experiment_json = params.experiment_json
genome_reference = params.ref_genome_filename
transcriptome_reference = params.ref_transcriptome_filename
coverage_file = params.sj_filename
input_read_model_map = params.read_model_map_filename
ref_dir = Channel.fromPath( params.public_ref_dir, type: 'dir' )
tool_name = params.participant_id.replaceAll("\\s","_")
gold_standards_dir = Channel.fromPath(params.goldstandard_dir, type: 'dir' )
if(params.challenges_ids instanceof List) {
		challenges_ids = params.challenges_ids.join(" ")
} else {
		challenges_ids = params.challenges_ids
		challenges_ids.replace("\"", "")
}
benchmark_data = Channel.fromPath(params.assess_dir, type: 'dir' )
community_id = params.community_id

// output 
validation_file = file(params.validation_result)
assessment_file = file(params.assessment_results)
aggregation_dir = file(params.outdir, type: 'dir')
augmented_benchmark_data = file(params.augmented_assess_dir, type: 'dir')
data_model_export_dir = file(params.data_model_export_dir)

// other
other_dir = file(params.otherdir, type: 'dir')


process validation {

	// validExitStatus 0,1
	tag "Validating input file format"
	
	publishDir "${validation_file.parent}", saveAs: { filename -> validation_file.name }, mode: 'copy'

	input:
	path input_dir
	file input_gtf
	file input_cage_peak
	file input_polyA
	file entry_json
	file experiment_json
	file genome_reference
	file transcriptome_reference
	file coverage_file
	file input_read_model_map
	path ref_dir
	val challenges_ids
	val tool_name
	val community_id

	output:
	val task.exitStatus into EXIT_STAT
	file 'validation.json' into validation_out

	
	"""
	python /app/validation.py -i $input_dir -c $input_cage_peak -p $input_polyA -e $entry_json -x $experiment_json -g $input_gtf -r $input_read_model_map -o validation.json
	"""

}

process compute_metrics {

	tag "Computing benchmark metrics for submitted data"
	
	publishDir "${assessment_file.parent}", saveAs: { filename -> assessment_file.name }, mode: 'copy'

	input:
	val file_validated from EXIT_STAT
	file input_file
	val cancer_types
	path gold_standards_dir
	val tool_name
	val community_id

	output:
	file 'assessment.json' into assessment_out

	when:
	file_validated == 0

	// TODO fix this command
	"""
	conda run -n sqanti_env python /app/sqanti3_lrgasp.challenge1.py "$input_dir"/models.gtf "$input_dir"/lrgasp_gencode_vM27_sirvs.gtf "$input_dir"/lrgasp_grcm39_sirvs.fasta --gtf --experiment_json input/experiment.json --entry_json input/entry.json --cage_peak input/cage_peak_mouse.bed --polyA_motif_list input/polyA_list.txt -c input/SJ.out.tab -d results/ -o test
	"""

}

process benchmark_consolidation {

	tag "Performing benchmark assessment and building plots"
	publishDir "${aggregation_dir.parent}", pattern: "aggregation_dir", saveAs: { filename -> aggregation_dir.name }, mode: 'copy'
	publishDir "${data_model_export_dir.parent}", pattern: "data_model_export.json", saveAs: { filename -> data_model_export_dir.name }, mode: 'copy'
	publishDir "${augmented_benchmark_data.parent}", pattern: "augmented_benchmark_data", saveAs: { filename -> augmented_benchmark_data.name }, mode: 'copy'

	input:
	path benchmark_data
	file assessment_out
	file validation_out
	
	output:
	path 'aggregation_dir', type: 'dir'
	path 'augmented_benchmark_data', type: 'dir'
	path 'data_model_export.json'

	"""
	cp -Lpr $benchmark_data augmented_benchmark_data
	python /app/manage_assessment_data.py -b augmented_benchmark_data -p $assessment_out -o aggregation_dir
	python /app/merge_data_model_files.py -p $validation_out -m $assessment_out -a aggregation_dir -o data_model_export.json
	"""

}


workflow.onComplete { 
	println ( workflow.success ? "LRGASP challenge 1 benchmarking done!" : "Oops .. something went wrong" )
}
