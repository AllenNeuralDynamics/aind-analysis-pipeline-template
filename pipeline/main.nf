#!/usr/bin/env nextflow
// hash:sha256:ef04043ffe12ecc832769d740aa6c9370b594473d5d90b22f7b1f3eab266f336

nextflow.enable.dsl = 1

analysis_data_asset_ids_to_aind_analysis_job_dispatch_1 = channel.fromPath("../data/analysis_data_asset_ids", type: 'any')
capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_2 = channel.create()
analysis_parameters_to_aind_analysis_wrapper_3 = channel.fromPath("../data/analysis_parameters", type: 'any')

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_1 {
	tag 'capsule-9303168'
	container "$REGISTRY_HOST/capsule/a4b6e4fc-65b3-45f3-affc-6a0bf387d187"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	input:
	path 'capsule/data' from analysis_data_asset_ids_to_aind_analysis_job_dispatch_1.collect()

	output:
	path 'capsule/results/*' into capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_2

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=a4b6e4fc-65b3-45f3-affc-6a0bf387d187
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9303168.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9303168.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_job_dispatch_1_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-analysis-wrapper
process capsule_aind_analysis_wrapper_2 {
	tag 'capsule-7525633'
	container "$REGISTRY_HOST/capsule/ccdad30f-85a3-4c04-b24d-33fdbff8297c"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/job_dict' from capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_2.flatten()
	path 'capsule/data' from analysis_parameters_to_aind_analysis_wrapper_3.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=ccdad30f-85a3-4c04-b24d-33fdbff8297c
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7525633.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7525633.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_wrapper_2_args}

	echo "[${task.tag}] completed!"
	"""
}
