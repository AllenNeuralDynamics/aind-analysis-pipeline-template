#!/usr/bin/env nextflow
// hash:sha256:cd4c29e6e4aca7130bc1b9e1005b4a97e487326bdc1b17fff40bf0af39cb05af

nextflow.enable.dsl = 1

analysis_query_to_aind_analysis_job_dispatch_1 = channel.fromPath("../data/analysis_query/*", type: 'any')
analysis_parameters_to_aind_analysis_job_dispatch_2 = channel.fromPath("../data/analysis_parameters/*", type: 'any')
capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_3 = channel.create()

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_3 {
	tag 'capsule-3709532'
	container "$REGISTRY_HOST/published/d8136da9-6ebd-4881-acac-d054ca35d3ff:v2"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	input:
	path 'capsule/data/' from analysis_query_to_aind_analysis_job_dispatch_1
	path 'capsule/data/' from analysis_parameters_to_aind_analysis_job_dispatch_2

	output:
	path 'capsule/results/*' into capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_3

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=d8136da9-6ebd-4881-acac-d054ca35d3ff
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git -c credential.helper= clone --filter=tree:0 --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3709532.git" capsule-repo
	else
		git -c credential.helper= clone --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3709532.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_job_dispatch_3_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-analysis-wrapper
process capsule_aind_analysis_wrapper_4 {
	tag 'capsule-0652828'
	container "$REGISTRY_HOST/published/cc2e0121-97fe-4ad2-b9eb-7fc4767330ea:v1"

	cpus 1
	memory '7.5 GB'

	input:
	path 'capsule/data/job_dict' from capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_3.flatten()

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=cc2e0121-97fe-4ad2-b9eb-7fc4767330ea
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git -c credential.helper= clone --filter=tree:0 --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0652828.git" capsule-repo
	else
		git -c credential.helper= clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0652828.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_wrapper_4_args}

	echo "[${task.tag}] completed!"
	"""
}
