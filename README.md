# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/3390834/tree) is intended to provide a template for facilitating large scale analysis. The pipeline has 2 capsules:
[Job Dispatcher](#job-dispatcher) and [Analysis Wrapper](#analysis-wrapper).

### Recommended Workflow
1. Request a new collection in the analysis documentDB by filing an issue here: https://github.com/AllenNeuralDynamics/aind-scientific-computing/issues 
2. Duplicate this pipeline. Under the `pipeline` folder, modify the `nextflow.config` by replacing the **`aind-analysis-pipeline-template`** in the `process.resourceLabels` field with an apporiate and unique tag for this specific analysis pipeline. This will help monitor and control costs.
3. In addition to step 2, modify the `nextflow.config` by updating the necessary values: `ANALYSIS_BUCKET`, `CODEOCEAN_EMAIL`, and `DOCDB_COLLECTION`
4. From the duplicated pipeline, duplicate the **`analysis_wrapper`** capsule. **Replace the example wrapper capsule with the duplicated one**
5. Attach the necessary pipeline settings credentials by clicking on the pipleine settings widget at the far right. See screenshot below:
   <img width="1639" height="804" alt="image" src="https://github.com/user-attachments/assets/087b7ef3-6e85-49de-998b-68c2bc53dec2" />

6. Figure out docDB query or input data assets csv that are desired. Test with dispatch capsule if needed (should not need to duplicate unless have to manually implement grouping, just use app panel). See job dispatcher section.
7. Modify the duplicated analysis wrapper capsule - follow instructions in the readme for the wrapper. **Be sure to commit all changes**. [Analysis Wrapper Section](#analysis-wrapper)
8. At the pipeline level - modify the necessary input - analysis parameters.json, query, etc. to reflect the wrapper and expected dispatch output. [Analysis Pipeline Input](#analysis-pipeline-input)
9. Run the pipeline with relevant input arguments specified. When ready, set the dry run argument in app panel to 0 after testing to write results to S3 and docDB.

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/3709532/tree). This capsule fetches information about data assets that the user wants to run analysis on. Input arguments can be found in the app panel. See sample screenshot below:

<img width="390" height="813" alt="image" src="https://github.com/user-attachments/assets/a6f2841a-961e-41cb-bbea-e28ab5eb2813" />

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


