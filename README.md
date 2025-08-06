# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/3390834/tree) is intended to provide a template for facilitating large scale analysis. The pipeline has 2 capsules:
[Job Dispatcher](#job-dispatcher) and [Analysis Wrapper](#analysis-wrapper).

### Recommended Workflow
1. Set up analysis collection in document database and S3 bucket. Reach out to data infrastructure team for this
2. Duplicate the pipeline after S3 bucket and document database collection have been setup
3. From the duplicated pipeline, duplicate the **`analysis_wrapper`** capsule. **Replace the example wrapper capsule with the duplicated one**
4. Figure out docDB query or input data assets csv that are desired. Test with dispatch capsule if needed (should not need to duplicate unless have to manually implement grouping, just use app panel). See job dispatcher section.
5. Modify the duplicated analysis wrapper capsule - follow instructions in the readme for the wrapper. **Be sure to commit all changes**. [Analysis Wrapper Section](#analysis-wrapper)
6. At the pipeline level - modify the necessary input - analysis parameters.json, query, etc. to reflect the wrapper and expected dispatch output. [Analysis Pipeline Input](#analysis-pipeline-input)
7. Run the pipeline with relevant input arguments specified. When ready, set the dry run argument in app panel to 0 after testing to write results to S3 and docDB.

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/3709532/tree). This capsule fetches information about data assets that the user wants to run analysis on. Input arguments in app panel are below:

| Argument               | Type    | Description                                                                                                                                             |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--query`  | string | Path to the json file with the docDB query: **`/data/input_query.json`** or paste the representation of the query.
| `--file_extension`      | string  | The file extension to search for from the bucket returned by the query (**For example: nwb or zarr**). Default is empty                                                                                                             |
| `--split_files`   | int  | Either group the files into one list if multiple files are returned for the file extension or split into single input per file. Default is to split
| `--tasks_per_job`    | int  |  The number of tasks per job. Default is 1 task per job. For example, if this is set to 3 and there are 10 tasks, then there will be 4 jobs dispatched.
| `--max_number_of_tasks_dispatched`  | int  | Maximum number of tasks to be dispatched. Default is 1000.
| `--use_data_asset_csv`  | int | Whether or not to use the data asset ids in the csv provided. Default is 0. If 1, there MUST be a csv in the `/data/analysis_data_asset_ids` folder called `data_asset_input.csv`, with the column `asset_id`. **Be sure to then replace the analysis_query with the analysis_data_asset_ids**. 
| `--group_by`  | int | Group asset query by a given field in the database schema (for example, by `subject_id`)

See [job_dispatch](https://github.com/AllenNeuralDynamics/aind-analysis-job-dispatch) readme for more details.

### Analysis Wrapper
The [analysis wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/0652828/tree) is the capsule where analysis is to be executed. **Users must first duplicate this capsule before running the pipeline and be sure to swap out the current one with duplicated one. The current capsule is meant to be an example**. 

See the [analysis wrapper](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) readme for **critical** details on environment setup, defining an analysis model, etc.

### Analysis Pipeline Input 
**If using a query from the json file: modify the query at the pipeline level in `/data/analysis_query/input_query.json`. In the app panel, set the path to `/data/input_query.json`. If pasting the query, paste the json string representation without leading or trailing quotes, for example `{"subject.subject_id": "774659"}`. If pasting, be sure to remove the connection to the analysis query input json file.**

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


