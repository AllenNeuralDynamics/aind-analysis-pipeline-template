# aind-analysis-pipeline-template

This [pipeline](https://codeocean.allenneuraldynamics.org/capsule/8624294/tree) is intended to provide a template for facilitating large scale analysis. First, duplicate the pipeline. The pipeline has 2 capsules:

### Job Dispatcher
The [job dispatch capsule](https://codeocean.allenneuraldynamics.org/capsule/9303168/tree). This capsule fetches information about data assets that the user wants to run analysis on. Input arguments are below:

| Argument               | Type    | Description                                                                                                                                             |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--query`  | string | Path to the json file with the docDB query or copy and paste the string representation of the query.
| `--file_extension`      | string  | The file extension to search for from the bucket returned by the query. Defualt is empty                                                                                                             |
| `--split_files`   | int  | Either group the files into one list if multiple files are returned for the file extension or split into single input per file. Default is to split
| `--num_parallel_workers`    | int  |  The number of parallel workers to output, default is 50
| `--use_data_asset_csv`  | int | Whether or not to use the data asset ids in the csv provided. Default is 0. If 1, there MUST be a csv in the `/data` folder called `data_asset_input.csv`, with the column `asset_id`.
| `--group_by`  | int | Group asset query by a given field in the database schema (for example, by `subject_id`)

### Analysis Wrapper
The [analysis wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/7739912/tree) is the capsule where analysis is to be executed. **Users must duplicate this capsule before running the pipeline. The current capsule is meant to be an example**.


