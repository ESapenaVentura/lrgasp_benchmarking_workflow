# lrgasp_benchmarking_workflow


# Data from original lrgasp

- All challenges (categories) of data that only had 1 participant (e.g. `3_polya_supported_r2c2_ont_ls`) have been deleted.

# Categories

| | | | |
|------------------------------------|---------------------------------------|------------------------------------|-------------------------|
|iso_detect_ref_WTC11_drna_ont_ls|iso_detect_ref_WTC11_captrap_pacbio_lo|iso_detect_ref_WTC11_drna_ont_lo|iso_detect_ref_WTC11_cdna_pacbio_lo|
|iso_detect_ref_WTC11_cdna_pacbio_ls|iso_detect_ref_WTC11_cdna_ont_lo|iso_detect_ref_WTC11_r2c2_ont_lo|iso_detect_ref_WTC11_captrap_ont_lo|
|iso_detect_ref_WTC11_cdna_ont_ls|

For more information on the categories and what they mean, please visit the [LRGASP RNA-Seq Data Matrix](https://lrgasp.github.io/lrgasp-submissions/docs/rnaseq-data-matrix.html)

# Metrics

For all categories, the following metrics are used:

## Metrics included

### FSM, ISM, NIC, NNC metrics

#### Bar-plots
| | | |
|-------|--------|---------|
|3' polyA supported|5' Reference supported (transcript)|rt-switching incidence|
|Full illumina SJ support|Supported novel transcript model (SNTM)|3' Reference supported (transcript)|
|5' CAGE supported|5' Reference supported (gene)|Supported reference transcript model (SRTM)|
|Reference Match|Intron retention incidence|5' and 3' reference supported (gene)|
|non-canonical SJ incidence|Intra-priming|3' reference supported (gene)|
|3' QuantSeq supported|||


#### 2d plots

| | | 
|-----------------------------------|---------------------------------------|
| 5' reference supported (transcript) vs 5' CAGE supported |3' reference supported (transcript) vs 3' QuantSeq supported |

These metrics,apart from the SIRV-related ones, are divided into:
- FSM (Full Splice Match)
- ISM (Incomplete Splice Match)
- NIC (Novel in Catalog)
- NNC (Novel Not in Catalog)


### SIRV metrics

Since the sequence of the SIRVs is known, these can be used as reference metrics, and are calculated as such:

| | | |
|-----------------------------------|---------------------------------------|------|
|Positive Detection Rate|False detection rate|False discovery rate|
|Non redundant precision|Sensitivity|Precision|

For more information on what each of these mean, please visit the [LRGASP Guidelines and tool](https://lrgasp.github.io/lrgasp-submissions/docs/) page
