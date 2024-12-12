# Data Visualisation

## Table of Contents
<!-- TOC -->
* [Data Visualisation](#data-visualisation)
  * [Table of Contents](#table-of-contents)
  * [Filtering Data](#filtering-data)
    * [Information](#information)
    * [Cleanup Results](#cleanup-results)
      * [Data CSV](#data-csv)
      * [Topo JSON](#topo-json)
    * [Numerical Bindings](#numerical-bindings)
      * [`english_proficiency` Column](#english_proficiency-column)
      * [`industry` Column](#industry-column)
      * [`qualification` Column](#qualification-column)
      * [`deprivation` Column](#deprivation-column)
    * [Setup](#setup)
<!-- TOC -->

## Filtering Data
### Information
The original data CSV (53.42M) is too large for Elm-Litvis ability to even load the data.
While attempting to just load the data without plotting anything, Visual Studio Code froze and produced no graph, and on 2 occasions even crashed outright.

For this reason I have used a separate script to remove a lot of unnecessary data.
The cleanup does the following:
- Renames all output columns to something more manageable
- Removes all instances of no observations
- Removes all unnecessary/duplicate columns
- Removes all "not applicable" data which is pointless for the visualsation

In addition to cleaning and filtering the CSV data, I have taken this opportunity to filter the topography JSON file to ensure better performance.
I have removed all properties, since they will be unused, and I have removed breaklines and indentation.
This reduces the file size and character count by a drastic amount in hopes that Elm-Litvis will handle this data a lot smoother.

### Cleanup Results
#### Data CSV
**Rows**:
157248 -> 50253 (106995 rows / 68.0% removed)<br/>
**File size**:
53.42M -> 1.61M (51.80M / 97.0% reduction)

#### Topo JSON
**File size**:
5.32M -> 1.22M (4.10M / 77.1% reduction)

### Numerical Bindings
Each column is represented by a numerical value, similar to how an enum represents data in many popular languages.
This section of the document definees the bindings between those numerical values and their original meaning.

#### `english_proficiency` Column

| Value | Meaning                                                                                                     |
|------:|:------------------------------------------------------------------------------------------------------------|
|     1 | Main language is English (English or Welsh in Wales)                                                        |
|     2 | Main language is not English (English or Welsh in Wales)                                                    |
|     3 | Main language is not English (English or Welsh in Wales): Cannot speak English or cannot speak English well |

#### `industry` Column

| Value | Meaning                                                                       |
|------:|:------------------------------------------------------------------------------|
|     1 | A, B, D, E Agriculture, energy and water                                      |
|     2 | C Manufacturing                                                               |
|     3 | F Construction                                                                |
|     4 | G, I Distribution, hotels and restaurants                                     |
|     5 | H, J Transport and communication                                              |
|     6 | K, L, M, N Financial, real estate, professional and administrative activities |
|     7 | O, P, Q Public administration, education and health                           |
|     8 | R, S, T, U Other                                                              |

#### `qualification` Column

| Value | Meaning                                                                                                                                                                                                                                                                                                                              |
|------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     0 | No qualifications                                                                                                                                                                                                                                                                                                                    |
|     1 | Level 1 and entry level qualifications: 1 to 4 GCSEs grade A* to C, Any GCSEs at other grades, O levels or CSEs (any grades), 1 AS level, NVQ level 1, Foundation GNVQ, Basic or Essential Skills                                                                                                                                    |
|     2 | Level 2 qualifications: 5 or more GCSEs (A* to C or 9 to 4), O levels (passes), CSEs (grade 1), School Certification, 1 A level, 2 to 3 AS levels, VCEs, Intermediate or Higher Diploma, Welsh Baccalaureate Intermediate Diploma, NVQ level 2, Intermediate GNVQ, City and Guilds Craft, BTEC First or General Diploma, RSA Diploma |
|     3 | Level 3 qualifications: 2 or more A levels or VCEs, 4 or more AS levels, Higher School Certificate, Progression or Advanced Diploma, Welsh Baccalaureate Advance Diploma, NVQ level 3; Advanced GNVQ, City and Guilds Advanced Craft, ONC, OND, BTEC National, RSA Advanced Diploma                                                  |
|     4 | Level 4 qualifications or above: degree (BA, BSc), higher degree (MA, PhD, PGCE), NVQ level 4 to 5, HNC, HND, RSA Higher Diploma, BTEC Higher level, professional qualifications (for example, teaching, nursing, accountancy)                                                                                                       |
|     5 | Other: apprenticeships, vocational or work-related qualifications, other qualifications achieved in England or Wales, qualifications achieved outside England or Wales (equivalent not stated or unknown)                                                                                                                            |

#### `deprivation` Column
| Value | Meaning                                               |
|------:|:------------------------------------------------------|
|     0 | Household is not deprived in the employment dimension |
|     1 | Household is deprived in the employment dimension     |


### Running

1. Set up a python virtual environment.
2. Install the required dependencies:
```
pip install -r requirements.txt
```
3. Run the script:
```
python src/data-cleanup.py
```
4. In the `data` directory, a minified versions of the data and json have been creaetd.
