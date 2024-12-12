# Data Visualisation

## Table of Contents
<!-- TOC -->
* [Data Visualisation](#data-visualisation)
  * [Table of Contents](#table-of-contents)
  * [Filtering Data](#filtering-data)
    * [Information](#information)
    * [Cleanup Results](#cleanup-results)
    * [Setup](#setup)
<!-- TOC -->

## Filtering Data
### Information
The original data (53.42M) is too large for Elm-Litvis ability to even load the data.
While attempting to just load the data without plotting anything, Visual Studio Code froze and produced no graph, and on 2 occasions even crashed outright.

For this reason I have used a separate script to remove a lot of unnecessary data.
The cleanup does the following:
- Renames all output columns to something more manageable
- Removes all instances of no observations
- Removes all unnecessary/duplicate columns
- Removes all "not applicable" data which is pointless for the visualsation

### Cleanup Results
**Rows**:
157248 -> 50253 (106995 rows / 68.0% removed)<br/>
**File size**:
53.42M -> 1.61M (51.80M / 97.0% reduction)

### Setup

1. Set up a python virtual environment.
2. Install the required dependencies:
```
pip install -r requirements.txt
```
3. Run the script:
```
python src/data-cleanup.py
```
4. In the `data` directory, a `minified.csv` has been created.
