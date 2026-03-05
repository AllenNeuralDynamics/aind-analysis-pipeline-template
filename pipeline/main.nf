#!/usr/bin/env nextflow
// hash:sha256:0a13540a34a351dc88a699e5347bcd6178a9cc4b1d1f261a7e9e3c94c8d24075

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_3 {
	tag 'capsule-3709532'
	container "$REGISTRY_HOST/published/d8136da9-6ebd-4881-acac-d054ca35d3ff:v3"

	cpus 1
	memory '7.5 GB'

	cache 'deep'

	input:
	path 'capsule/data/input_files'

	output:
	path 'capsule/results/*', emit: to_capsule_aind_analysis_wrapper_template_4_2

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
		git -c credential.helper= clone --filter=tree:0 --branch v3.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3709532.git" capsule-repo
	else
		git -c credential.helper= clone --branch v3.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-3709532.git" capsule-repo
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

// capsule - aind-analysis-wrapper-template
process capsule_aind_analysis_wrapper_template_4 {
	tag 'capsule-9982875'
	container "$REGISTRY_HOST/capsule/cffff209-3aa7-43b1-80fc-96df26466e76:f71a8948d52f7b7cc5bf1649d2c797b1"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/job_dict'

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=cffff209-3aa7-43b1-80fc-96df26466e76
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git -c credential.helper= clone --filter=tree:0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9982875.git" capsule-repo
	else
		git -c credential.helper= clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9982875.git" capsule-repo
	fi
	git -C capsule-repo checkout a0615bf9c141502825b8d5c08943ee7eecb712f1 --quiet
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_wrapper_template_4_args}

	echo "[${task.tag}] completed!"
	"""
}

workflow {
	// input data
	input_files_to_aind_analysis_job_dispatch_1 = Channel.fromPath("../data/input_files", type: 'any')

	// run processes
	capsule_aind_analysis_job_dispatch_3(input_files_to_aind_analysis_job_dispatch_1.collect())
	capsule_aind_analysis_wrapper_template_4(capsule_aind_analysis_job_dispatch_3.out.to_capsule_aind_analysis_wrapper_template_4_2.flatten())
}
