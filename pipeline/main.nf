#!/usr/bin/env nextflow
// hash:sha256:4d76450641b687f9c609f5a96274c11647f4628099defacf4bd196073e5806fb

nextflow.enable.dsl = 1

capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_1 = channel.create()

// capsule - aind-analysis-job-dispatch
process capsule_aind_analysis_job_dispatch_1 {
	tag 'capsule-9303168'
	container "$REGISTRY_HOST/capsule/a4b6e4fc-65b3-45f3-affc-6a0bf387d187"

	cpus 1
	memory '8 GB'

	output:
	path 'capsule/results/*' into capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_1

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=a4b6e4fc-65b3-45f3-affc-6a0bf387d187
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9303168.git" capsule-repo
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
	memory '8 GB'

	input:
	path 'capsule/data/' from capsule_aind_analysis_job_dispatch_1_to_capsule_aind_analysis_wrapper_2_1.flatten()

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=ccdad30f-85a3-4c04-b24d-33fdbff8297c
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-7525633.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_aind_analysis_wrapper_2_args}

	echo "[${task.tag}] completed!"
	"""
}
