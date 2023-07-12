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
inputsdir="${scriptdir}/input_dataset"

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

git_repo="$(jq -r '.arguments[] | select(.name=="nextflow_repo_uri") | .value' "${scriptdir}"/config.json)"
git_tag="$(jq -r '.arguments[] | select(.name=="nextflow_repo_tag") | .value' "${scriptdir}"/config.json)"
git clone -n "${git_repo}" "${repodir}"
cd "${repodir}" && git checkout "${git_tag}"

echo
echo "Fetching reference dataset for ${DATA_RELEASE}"

# Clone docker repository - Example data was deposited there
wget https://github.com/ESapenaVentura/lrgasp_docker/raw/main/example_data/iso_detect_ref_input_example/input_user_files.tar.gz && mv input_user_files.tar.gz "$inputsdir"/input_user_files.tar.gz


# Download reference genome and transcriptome
wget https://lrgasp.s3.amazonaws.com/lrgasp_grcm39_sirvs.fasta && mv lrgasp_grcm39_sirvs.fasta "$inputsdir"/lrgasp_grcm39_sirvs.fasta
synapse get syn26986100 && mv lrgasp_gencode_vM28_sirvs.mouse.gtf "$inputsdir"/lrgasp_gencode_vM28_sirvs.mouse.gtf

# Move the rest of the data
cp -r lrgasp_data/ "${datasetsdir}"


