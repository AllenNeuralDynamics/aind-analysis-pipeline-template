#!/usr/bin/env nextflow
// hash:sha256:36a8eeb35527a48e88333131e7ac46cb602d48721091db2bcc52c6f032aac94a

nextflow.enable.dsl = 1

input_data_to_aind_analysis_job_dispatch_1 = channel.fromPath("../data/input_data", type: 'any')
capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_2 = channel.create()

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_3 {
	tag 'capsule-9303168'
	container "$REGISTRY_HOST/capsule/a4b6e4fc-65b3-45f3-affc-6a0bf387d187:3c8b00bced1ceb20d002487251fc43f7"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	input:
	path 'capsule/data/input_data' from input_data_to_aind_analysis_job_dispatch_1.collect()

	output:
	path 'capsule/results/*' into capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_2

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
		git -c credential.helper= clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9303168.git" capsule-repo
	else
		git -c credential.helper= clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9303168.git" capsule-repo
	fi
	git -C capsule-repo checkout c47bb25b532e2cd7dda28a9135713f70431c1df4 --quiet
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_job_dispatch_3_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-analysis-wrapper-template
process capsule_aind_analysis_wrapper_4 {
	tag 'capsule-7739912'
	container "$REGISTRY_HOST/capsule/9f19f5fc-d91e-4d82-8bee-176783e1ca63:0ec7ca43a1c2314b100821d6da4c16c2"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/job_dict' from capsule_aind_analysis_job_dispatch_3_to_capsule_aind_analysis_wrapper_4_2.flatten()

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
		git -c credential.helper= clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7739912.git" capsule-repo
	else
		git -c credential.helper= clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7739912.git" capsule-repo
	fi
	git -C capsule-repo checkout 2bb5d32d6a83d643d6deccf05f70ab12f5798291 --quiet
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_wrapper_4_args}

	echo "[${task.tag}] completed!"
	"""
}
