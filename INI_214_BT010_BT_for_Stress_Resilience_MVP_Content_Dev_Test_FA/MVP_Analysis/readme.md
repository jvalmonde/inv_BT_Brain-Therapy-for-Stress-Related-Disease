# MVP Content Module
---------------------------------------

This module runs the feature extraction and statistical analysis of the MVP Content experiment (Focused Attention and Working Memory) and has three parts, which will be discussed in the following paragraphs. But before going to the main processes, there are a few necessary preprocessing steps that need to be done on the raw data. 

## Preprocessing Steps

### 1. Merging the sensor data and event data

Use **preprocessing.py** for this step and make sure that all the dependencies have been installed in the environment. What the script does is:

1. Load the raw data from the specified directory. The raw data we need are the sensor data (Biopac) and the event data (json file).
2. Temporally align the sensor data with the event data.
3. Remove the garbage parts of the signal, i.e., the signal before the start of the experiment, the signal between 2D and 3D, and the signal after the experiment.

The output of this step is a dictionary of dataframes of signal and event data for each of the participants.

### 2. Cleaning the signal manually

Manual signal curation is done to make sure that the quality of the signal we extract features from is good. This is expected to return a dataframe of the cleaned signals in ".pkl" format

## Main Processes

The main processes are compiled in one script: **run_project.py**. These processes use both Python (feature extraction and normality test) and R (statistical analysis). Before running the script, make sure that the dependencies for both have been installed. The script would need two arguments, the path to the sensor data in ".pkl" format and the path to the output directory.

    Sample: 
        run_project.py path_to_signals path_to_output

### 1. Feature Extraction

A total of 8 features were generated from 3 different sensors (ECG, Skin temperature, EDA). Here's the list of the features:
1. ECG heart rate
2. ECG heart rate variability
3. Skin Temperature
4. EDA mean
5. EDA low frequency
6. EDA high frequency
7. EDA high and low frequency ratio
8. EDA number of peaks

### 2. Feature Normality Test

Scipy's normality test was used to test the distribution of the features. Three different distributions of the features (original, log, and square root) were compared to the gaussian distribution where the distribution closest to the gaussian distribution was the one used for the analysis.

### 3. Statistical Analysis

Two Rmd codes were created for the statistical analysis: **fa_analysis.Rmd** and **wm_analysis.Rmd** which uses the R codes **helpers_fa.R** and **helpers_wm.R**, respectively. In the Rmd codes, the default working directory was set to be the directory containing the files (current directory). Therefore, the data must also be in this directory. The user can change the working directory and the data path directly from the Rmd file, if needed.


