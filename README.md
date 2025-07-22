# AIND Analysis Pipeline Template

## Overview

This [pipeline template](https://codeocean.allenneuraldynamics.org/capsule/8624294/tree) provides a scalable framework for running large-scale analyses on neural data stored in the AIND ecosystem. The pipeline uses a two-stage approach: data discovery and parallel analysis execution.

## Architecture

The pipeline consists of two main components that work together via Nextflow:

1. **Job Dispatcher**: Discovers and prepares data assets for analysis
2. **Analysis Wrapper**: Executes user-defined analysis on each data asset in parallel

## Quick Start

1. **Duplicate this pipeline** in Code Ocean
2. **Configure your data input** (see [Data Input Methods](#data-input-methods))
3. **Set up your analysis** (see [Analysis Configuration](#analysis-configuration))
4. **Run the pipeline**

## Pipeline Components

### 1. Job Dispatcher

The [Job Dispatcher capsule](https://codeocean.allenneuraldynamics.org/capsule/9303168/tree) handles data discovery and preparation. It queries the document database to find data assets matching your criteria and prepares them for parallel processing. It will also find all analysis parameters to run on each asset as defined in the `distributed_parameters.json`

#### Configuration Options

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--query` | string | - | MongoDB query filter (as dictionary string) or path to JSON file containing the query |
| `--file_extension` | string | "" | Specific file extension to search for within each data asset |
| `--split_files` | int | 1 | Whether to split multiple files into separate jobs (1) or group them together (0) |
| `--num_parallel_workers` | int | 50 | Maximum number of parallel analysis jobs to create |
| `--use_data_asset_csv` | int | 0 | Use CSV file instead of database query (1=yes, 0=no) |

#### Output Format

Each discovered data asset produces a JSON record with the following structure:

**Basic output (no file extension specified):**
```json
{
    "s3_location": ["s3://bucket/data-asset-id"],
    "asset_id": ["data-asset-id"],
    "asset_name": ["descriptive-name"],
    "distributed_parameters": [
        {
            "analysis_name": "foo",
            "analysis_value": 10.0,
            "analysis_version": 1.0
        }
    ],
    "file_location": []
}
```

**With file extension specified:**
```json
{
    "s3_location": ["s3://bucket/data-asset-id"],
    "asset_id": ["data-asset-id"], 
    "asset_name": ["descriptive-name"],
    "distributed_parameters": [
        {
            "analysis_name": "foo",
            "analysis_value": 10.0,
            "analysis_version": 1.0
        }
    ],
    "file_location": ["s3://bucket/data-asset-id/path/to/file.ext"]
}
```

### 2. Analysis Wrapper

The [Analysis Wrapper capsule](https://codeocean.allenneuraldynamics.org/capsule/7739912/tree) executes your custom analysis code on each data asset in parallel.

Key features:
- Receives data asset information from the Job Dispatcher
- Downloads data from S3 locations
- Runs user-defined analysis code
- Uploads results to S3
- Records metadata in the document database

## Data Input Methods

### Method 1: Database Query (Recommended)

Create a JSON file in `data/analysis_query/input_query.json` with your MongoDB query:

```json
{
    "subject.subject_id": "774659",
    "data_description.process_name": "processed"
}
```

### Method 2: CSV Asset List

For predefined lists of data assets:

1. Set `--use_data_asset_csv=1`
2. Create `data/analysis_data_asset_ids/data_asset_input.csv`:

```csv
asset_id
d94ab360-f393-41f4-831f-e098f11803df
a52edfb8-0f42-4ad4-899d-1801e9a550ae
```

> **Note**: CSV method overrides the database query when enabled.

## Analysis Configuration

### 1. Define Analysis Parameters

Edit `data/analysis_parameters/distributed_parameters.json` with your analysis configuration:

```json
[
    {
        "analysis_name": "Your Analysis Name",
        "analysis_tag": "Version or description",
        "custom_parameter": "your_value"
    }
]
```

### 2. Implement Analysis Logic

In the Analysis Wrapper capsule:

1. **Duplicate the Analysis Wrapper capsule**
2. **Define your analysis schema** in `analysis_wrapper/analysis_model.py`
3. **Implement your analysis code** in the appropriate module
4. **Test with sample data**

## Advanced Configuration

### File Grouping

For analyses requiring multiple files per job, set `--split_files=0`. You can implement custom grouping logic in the Job Dispatcher code.

### Resource Management

Adjust parallel processing limits in `pipeline/nextflow.config`:

```groovy
process {
    maxForks = 50
    queueSize = 50
}
```

### Output Management

Results are automatically:
- Saved to `/results/` in Code Ocean
- Uploaded to S3 (path configured via environment variables)
- Registered in the document database with full provenance

## Environment Variables

Required environment variables (typically set automatically in Code Ocean):
- `CO_COMPUTATION_ID`: Computation identifier
- `AWS_DEFAULT_REGION`: AWS region (default: us-west-2)

See the [Analysis Wrapper documentation](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper) for additional S3 and database configuration options.

## Troubleshooting

### Common Issues

1. **No data assets found**: Check your query syntax and ensure data exists in the database
2. **Analysis fails**: Verify your analysis parameters schema matches your implementation
3. **Resource limits**: Adjust `maxForks` and `queueSize` in nextflow.config if jobs are queuing

### Getting Help

- Review the [Analysis Wrapper documentation](https://github.com/AllenNeuralDynamics/aind-analysis-wrapper)
- Check Code Ocean logs for detailed error messages
- Verify your analysis works with sample data before scaling up 
