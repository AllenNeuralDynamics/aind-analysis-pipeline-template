# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/8624294/tree) is intended to provide a template for facilitating large scale analysis. First, duplicate the pipeline. The pipeline has 2 capsules:

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/9303168/tree). This capsule fetches information about data assets that the user wants to run analysis on. Input arguments in app builder are below:

| Argument               | Type    | Description                                                                                                                                             |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--query`  | string | Path to the json file with the docDB query in **`/data/analysis_query/input_query.json`** or paste the representation of the query.
| `--file_extension`      | string  | The file extension to search for from the bucket returned by the query. Defualt is empty                                                                                                             |
| `--split_files`   | int  | Either group the files into one list if multiple files are returned for the file extension or split into single input per file. Default is to split
| `--tasks_per_job`    | int  |  The number of tasks per job. Default is 1 task per job. For example, if this is set to 3 and there are 10 tasks, then there will be 4 jobs dispatched.
| `--use_data_asset_csv`  | int | Whether or not to use the data asset ids in the csv provided. Default is 0. If 1, there MUST be a csv in the `/data/analysis_data_asset_ids` folder called `data_asset_input.csv`, with the column `asset_id`. **Be sure to then replace the connection to the analysis_query and set it to connect to the analysis_data_asset_ids**
| `--group_by`  | int | Group asset query by a given field in the database schema (for example, by `subject_id`)

See [job_dispatch](https://github.com/AllenNeuralDynamics/aind-analysis-job-dispatch) for more details.

### Analysis Wrapper
The [analysis wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/7739912/tree) is the capsule where analysis is to be executed. **Users must duplicate this capsule before running the pipeline and be sure to swap out the current one with duplicated one. The current capsule is meant to be an example**.

User defined analysis can be specified in the **`run_analysis`** function in `run_capsule.py`. **If there was no file extension specified when dispatching, change example in line 30 to s3_location. Then users will need to read from the s3 bucket directly**.

### Analysis Wrapper - User Defined Analysis Parameters
To help faciliate tracking of analysis parameters, a user should define their own pydantic model in the **analysis wrapper**. Follow steps below:
1. In the file `/code/example_analysis_model.py`, first rename this to user's own model.
2. Then add any fields that need to be kept track of. ***Recommeneded to add a field to tag the version run***.
3. Additionally, for any numerical outputs - define these in the output model.
4. Once this is done, be sure to change lines **9, 38 66, and 69** to the user defined model, and user defined output model respectively.

### Analysis Pipeline Input 
The main file that needs to be modified is `/data/analysis_parameters/analysis_parameters.json`. Sumary of key points is below:
* There are 2 keys **fixed_parameters**, and **distributed_parameters**.
* Distributed parameters are **optional** and any parameters that will be used when dispatching. A product of distributed parameters x input data will be computed in the dispatcher.
* Fixed parameters are constant for the specified analysis and should be specified to help track.
* These parameters will then be automatically merged in the analysis wrapper. **Make sure the combination matches with the pydantic model defined in the analysis wrapper**. Example shown below

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

The corresponding model defined in the analysis wrapper:
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

Currently, users can also specify fixed parameters using the app panel and command line in the **analysis wrapper**. If these are specified, they will get merged in the wrapper automatically. **Again, be sure the combination of these matches the model defined**.

See the [analysis wrapper](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) for more details on enviornment setup, etc.

### Reporting Issues
Utility functions that users do not need to modify are defined in this package here [analysis_pipeline_utils](https://github.com/AllenNeuralDynamics/analysis-pipeline-utils). Report issues there if there are bugs with any functions from the package.


