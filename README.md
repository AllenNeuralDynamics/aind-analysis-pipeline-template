# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/3390834/tree) is intended to provide a template for facilitating large scale analysis. The pipeline has 2 capsules:
[Job Dispatcher](#job-dispatcher) and [Analysis Wrapper](#analysis-wrapper).

### Getting started
1. Create your analysis pipeline from the [aind-analysis-pipeline-template repo](https://github.com/AllenNeuralDynamics/aind-analysis-pipeline-template) and clone it into Code Ocean (preferred approach), or directly duplicate the [release pipeline template](https://codeocean.allenneuraldynamics.org/capsule/3390834/tree). In your new pipeline, update the name and author information in the pipeline metadata, and copy the name into the `process.resourceLabels` field in the `nextflow.config` file. 
2. Create your analysis wrapper capsule from the [aind-analysis-wrapper-template repo](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper-template) and clone it into Code Ocean (preferred approach), or directly duplicate the [release capsule template](https://codeocean.allenneuraldynamics.org/capsule/3390834/tree). Update the capsule name and author information.
3. **In your pipeline, replace the example wrapper capsule with your wrapper capsule from the pipeline builder interface.**
4. Attach the necessary pipeline credentials by clicking on the pipeline settings widget at the far right. See screenshot below:
   <img width="1639" height="804" alt="image" src="https://github.com/user-attachments/assets/087b7ef3-6e85-49de-998b-68c2bc53dec2" />
You will also need to do this at the capsule level when testing the component capsules below.
5. Figure out a docDB query for input data assets, and test in a reproducible run of the dispatch capsule (via the app panel). See [Job Dispatcher Section](#job-dispatcher). (If a query is not possible for your desired selection of assets, discuss metadata improvements with SciComp and use an uploaded CSV in the meantime.)
6. Add your analysis code to the analysis wrapper capsule ([Analysis Wrapper Section](#analysis-wrapper)). You may want to test this first in an interactive session. Test in a reproducible run by editing `/data/job_dict/example_dispatch_input` to reflect valid input data assets and parameters. **Be sure to commit all changes**.
7. At the pipeline level, modify the app panel inputs and/or input files (parameters and query) based on your testing ([Analysis Pipeline Input](#analysis-pipeline-input)), and try a reproducible run in dry-run mode.
### To run your pipeline at scale / "in production"
1. Request a new collection in the analysis documentDB by filing an issue here: https://github.com/AllenNeuralDynamics/aind-scientific-computing/issues 
2. Update the DOCDB_COLLECTION and ANALYSIS_BUCKET variables in the wrapper capsule (`settings.env`) and pipeline (`nextflow.config`).
3.  Set the dry run argument in app panel to 0 to write results to S3 and docDB. Test on a small number of records and confirm the results are as expected before proceeding to large-scale runs.

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/3709532/tree/) fetches information about data assets that the user wants to run analysis on, and organizes it into job records to be passed to workers. Input arguments can be found in the app panel. See sample screenshot below:

<img width="390" height="813" alt="image" src="https://github.com/user-attachments/assets/a6f2841a-961e-41cb-bbea-e28ab5eb2813" />

See [job_dispatch](https://github.com/AllenNeuralDynamics/aind-analysis-job-dispatch) readme for more details.

### Analysis Wrapper
The analysis wrapper capsule is where analysis is actually defined and executed. **Users create their own capsule from the template, which provides a minimal working example**: https://codeocean.allenneuraldynamics.org/capsule/0652828/tree/. 

See the [analysis wrapper](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) readme for **critical** details on environment setup, defining analysis parameter models, etc.

### Analysis Pipeline Input 
If using a query from the json file: modify the query at the pipeline level in `/data/analysis_query/input_query.json`. In the app panel, set the path to `/data/input_query.json`. If pasting the query, paste the json string representation without leading or trailing quotes, for example `{"subject.subject_id": "774659"}`.

The main file that needs to be modified is `/data/analysis_parameters/analysis_parameters.json`. Summary of key points is below:
* There are 2 keys **fixed_parameters**, and **distributed_parameters**.
* **`fixed_parameters`**: A single dictionary following your analysis input schema (or a subset of those fields). Use this when you want to run a single set of analysis parameters (N assets → N jobs).
* **`distributed_parameters`**: A list of dictionaries, each following your analysis input schema (or a shared subset of those fields). Use this when you want to run multiple different analyses on all assets (N assets × M parameter sets → N×M jobs). 
* **The analysis framework tools will merge these, together with any command-line or app-panel inputs, and the final merged parameter set will be validated against the analysis input schema specified in the wrapper.** Example shown below

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


