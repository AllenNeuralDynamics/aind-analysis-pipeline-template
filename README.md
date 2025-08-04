# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/8624294/tree) is intended to provide a template for facilitating large scale analysis. The pipeline has 2 capsules:
[Job Dispatcher](#job-dispatcher) and [Analysis Wrapper](#analysis-wrapper)

### Recommended Workflow
1. Set up analysis collection in document database and S3 bucket. Reach out to data infrastructure team for this
2. Duplicate the pipeline
3. From the duplicated pipeline, duplicate the **`analysis_wrapper`** capsule. **Replace the example wrapper capsule with the duplicated one**
4. Modify the duplicated analysis wrapper capsule - follow instructions in the readme for the wrapper. **Be sure to commit all changes**. [Analysis Wrapper Section](#analysis-wrapper)
5. At the pipeline level - modify the necessary files - analysis parameters.json, query, etc. to reflect the wrapper and expected dispatch output. [Analysis Pipeline Input](#analysis-pipeline-input)
6. Run the pipeline

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/9303168/tree). This capsule fetches information about data assets that the user wants to run analysis on. Input arguments in app panel are below:

| Argument               | Type    | Description                                                                                                                                             |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--query`  | string | Path to the json file with the docDB query in **`/data/analysis_query/input_query.json`** or paste the representation of the query.
| `--file_extension`      | string  | The file extension to search for from the bucket returned by the query. Default is empty                                                                                                             |
| `--split_files`   | int  | Either group the files into one list if multiple files are returned for the file extension or split into single input per file. Default is to split
| `--tasks_per_job`    | int  |  The number of tasks per job. Default is 1 task per job. For example, if this is set to 3 and there are 10 tasks, then there will be 4 jobs dispatched.
| `--use_data_asset_csv`  | int | Whether or not to use the data asset ids in the csv provided. Default is 0. If 1, there MUST be a csv in the `/data/analysis_data_asset_ids` folder called `data_asset_input.csv`, with the column `asset_id`. **Be sure to then replace the connection to the analysis_query and set it to connect to the analysis_data_asset_ids**
| `--group_by`  | int | Group asset query by a given field in the database schema (for example, by `subject_id`)

See [job_dispatch](https://github.com/AllenNeuralDynamics/aind-analysis-job-dispatch) readme for more details.

### Analysis Wrapper
The [analysis wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/7739912/tree) is the capsule where analysis is to be executed. **Users must first duplicate this capsule before running the pipeline and be sure to swap out the current one with duplicated one. The current capsule is meant to be an example**. 

See the [analysis wrapper](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) readme for **critical** details on environment setup, defining an analysis model, etc.

### Analysis Pipeline Input 
The main file that needs to be modified is `/data/analysis_parameters/analysis_parameters.json`. Summary of key points is below:
* There are 2 keys **fixed_parameters**, and **distributed_parameters**.
* **`fixed_parameters`**: A single dictionary following your analysis input schema. Use this when you want to run the same analysis parameters on all data assets (N assets → N jobs).
* **`distributed_parameters`**: A list of dictionaries, each following your analysis input schema. Use this when you want to run multiple different analyses (N assets × M parameter sets → N×M jobs). **These will be part of the model that the dispatcher outputs**.
* **The analysis wrapper capsule then merges these, together with any command-line or app-panel inputs, and the final merged parameter set should follow the analysis input schema specified in the wrapper.** Example shown below

```json
{
    "fixed_parameters": {
        "analysis_name": "Unit Quality Filtering",
        "analysis_tag": "baseline_v1.0",
        "isi_violations_cutoff": 0.05
    },
    "distributed_parameters": [
        {
            "method": "isolation_distance"
        },
        {
            "method": "amplitude_cutoff"
        }
    ]
}
```

The corresponding model defined in the **`analysis wrapper`**:
```
class UnitFilteringModel:
    analysis_name: str = Field(
        ..., description="User-defined name for the analysis"
    )
    analysis_tag: str = Field(
        ...,
        description=(
            "User-defined tag to organize results "
            "for querying analysis output",
        ),
    )
    isi_violations_cutoff: float = Field(
        ..., description="The value to be using when filtering units for isi_violations"
    )
    method: str = Field(
        ..., description="The method to filter units"
    )
```

### Reporting Issues
Utility functions that users do not need to modify are defined in this package here [analysis_pipeline_utils](https://github.com/AllenNeuralDynamics/analysis-pipeline-utils). Report issues there if there are bugs with any functions from the package.


