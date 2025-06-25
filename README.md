# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/8624294/tree) is intended to provide a template for facilitating large scale analysis. First, duplicate the pipeline. The pipeline has 2 capsules:

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/9303168/tree). This capsule fetches information about data assets that the user wants to run analysis on. Users can either specify a docdb query (in a json file or pasted into the app panel). The minimal output model is shown below for a record returned from the query. Each record will be saved to its own result folder to parallelize downstream analysis:

```json
{
    "s3_location": [
        "s3://codeocean-s3datasetsbucket-1u41qdg42ur9/50fa9416-4e21-482f-8901-889322a87ae3"
    ],
    "asset_id": [
        "50fa9416-4e21-482f-8901-889322a87ae3"
    ],
    "asset_name": [
        "behavior_774659_2025-06-07_14-31-15_processed_2025-06-08_03-49-49"
    ],
    "file_location": [
    ]
}
```

In addition, users can specify a file extension to look for as an input argument. An example output is shown below 
```json
{
    "s3_location": [
        "s3://codeocean-s3datasetsbucket-1u41qdg42ur9/50fa9416-4e21-482f-8901-889322a87ae3"
    ],
    "asset_id": [
        "50fa9416-4e21-482f-8901-889322a87ae3"
    ],
    "asset_name": [
        "behavior_774659_2025-06-07_14-31-15_processed_2025-06-08_03-49-49"
    ],
    "file_location": [
        "s3://codeocean-s3datasetsbucket-1u41qdg42ur9/50fa9416-4e21-482f-8901-889322a87ae3/nwb/behavior_774659_2025-06-07_14-31-15.nwb"
    ]
}
```

There is an alternative method for specifying data input. Users can specify a csv with a column `asset_id` which the pipeline will use, when the input argument `use_data_asset_csv` is set to value **1**.

If you need to group data assets, see the portion in the code where you can specify your own grouping however you like.

### Analysis Wrapper
The [analysis wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/7739912/tree) is the capsule where analysis is to be executed. First, duplicate this capsule.

In this capsule, users must provide their own analysis schema before running. First, it must be defined in `analysis_wrapper/example_analysis_model.py`. Then, create a json that follows this and replace the existing analysis parameters json in the pipeline with the one you defined (keep the name the same). 

The wrapper will then use the output from the dispatcher (parallelized across records returned from the dispatcher), and will then run the user defined analysis. Once analysis is complete, the output folder (`/results/` in Code Ocean) will be copied to the S3 location specified, and a metadata record will be written to the document database containing the input data, analysis model, and output location. See the [readme](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) for more details about setting the output S3 path and other necessary environment variables. 
