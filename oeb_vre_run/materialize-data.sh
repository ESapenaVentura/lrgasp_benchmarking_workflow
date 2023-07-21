#!/bin/sh

DATA_RELEASE=2022

if ! command -v synapse &> /dev/null ;
then
  echo "Please ensure you have synapse installed as a CLI; instructions here http://python-docs.synapse.org/build/html/index.html#installation. Also please ensure, once installed, that you are registered";
  exit
fi

scriptdir="$(dirname "$0")"
case "$scriptdir" in
	/*)
		true
		;;
	.)
		scriptdir="$(pwd)"
		;;
	*)
		scriptdir="$(pwd)/${scriptdir}"
		;;
esac

datasetsdir="${scriptdir}/reference_datasets"
inputsdir="${scriptdir}/lrgasp_data"
mkdir $inputsdir

repodir="${scriptdir}/the_repo"
cleanup() {
	set +e
	# This is needed in order to avoid
	# potential "permission denied" messages
	if [ -e "${repodir}" ] ; then
		chmod -R u+w "${repodir}"
		rm -rf "${repodir}"
	fi
}
trap cleanup EXIT ERR

cleanup
set -e
#rm -rf "${datasetsdir}" "${inputsdir}"

echo "Fetching reference dataset for ${DATA_RELEASE}"

mkdir "$inputsdir"/input_data
# Clone the already existing data from the lrgasp docker
git clone https://github.com/ESapenaVentura/lrgasp_docker.git
mv lrgasp_docker/data/ "$inputsdir"/aggregation_dir/
mv lrgasp_docker/example_data/iso_detect_ref_input_example/input_user_files.tar.gz "$inputsdir"/input_data/input_user_files.tar.gz
# Delete repository
rm -r lrgasp_docker


# Download reference files
mkdir "$inputsdir"/input_data/public_ref
wget https://lrgasp.s3.amazonaws.com/lrgasp_grcm39_sirvs.fasta && mv lrgasp_grcm39_sirvs.fasta "$inputsdir"/input_data/public_ref/lrgasp_grcm39_sirvs.fasta
synapse get syn26986100 && mv lrgasp_gencode_vM28_sirvs.mouse.gtf "$inputsdir"/input_data/public_ref/lrgasp_gencode_vM28_sirvs.mouse.gtf
synapse get syn26986190 && mv es_rep1SJ.out.tab "$inputsdir"/input_data/public_ref/es_rep1SJ.out.tab
synapse get syn27249518 && mv mouse.refTSS_v3.1.mm39.bed "$inputsdir"/input_data/public_ref/mouse.refTSS_v3.1.mm39.bed



