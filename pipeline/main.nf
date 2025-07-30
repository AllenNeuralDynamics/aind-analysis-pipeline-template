#!/usr/bin/env nextflow
// hash:sha256:5ee527f2e7791cb52a98cfb40af87e30b53feb367d49c1a21c5a392cfa41c269

nextflow.enable.dsl = 1

analysis_parameters_to_aind_analysis_job_dispatch_1 = channel.fromPath("../data/analysis_parameters/*", type: 'any')
analysis_query_to_aind_analysis_job_dispatch_2 = channel.fromPath("../data/analysis_query", type: 'any')
analysis_parameters_to_aind_analysis_wrapper_3 = channel.fromPath("../data/analysis_parameters", type: 'any')
capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_4 = channel.create()

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_1 {
	tag 'capsule-9303168'
	container "$REGISTRY_HOST/capsule/a4b6e4fc-65b3-45f3-affc-6a0bf387d187"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	input:
	path 'capsule/data/' from analysis_parameters_to_aind_analysis_job_dispatch_1
	path 'capsule/data' from analysis_query_to_aind_analysis_job_dispatch_2.collect()

	output:
	path 'capsule/results/*' into capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_4

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
	tag 'capsule-7739912'
	container "$REGISTRY_HOST/capsule/9f19f5fc-d91e-4d82-8bee-176783e1ca63"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data' from analysis_parameters_to_aind_analysis_wrapper_3.collect()
	path 'capsule/data/job_dict' from capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_4.flatten()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=9f19f5fc-d91e-4d82-8bee-176783e1ca63
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7739912.git" capsule-repo
	else
		git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7739912.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}
