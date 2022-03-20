#! /usr/bin/env python

import os 
import sys

import pandas as pd
import numpy as np
import joblib
import matplotlib.pyplot as plt
import neurokit as nk
import scipy as sc
import scipy.signal as ss
import math 
import itertools
import _03_feature_distribution as fd


from scipy import signal


def change_context(dataframe):
    new_df = dataframe.reset_index()
    
    #Filling nans
    new_df['context'] = new_df['context'].ffill()
    new_df['type'] = new_df['type'].ffill()
    new_df['context'] = new_df['context'].fillna("Garbage")
    new_df['type'] = new_df['type'].fillna("Garbage")
    new_df = new_df.reset_index().set_index(["Participant","type","context","Datetime"])
    return new_df

def get_ecg_peaks(data):
    """
    Takes the datetimes of the peaks 
    
    Input:
        data (dataframe) : Dataframe of participant's raw signal
    Output:
        time_stamps (series) : Series of timestamps of the peaks
    
    """
    
    data = data.reset_index()
    time_stamps = data[data["peaks_flag"]==1]["Datetime"]
    return time_stamps
    
def get_time_diff(sensor_data, participants):
    """
    Computes for the time difference of peak-to-peak intervals"
    
    Input:
        sensor_data (dataframe) : Dataframe of sensor signals
        participants (list) : List of names of the participants
    Output:
        time_diff_df (dataframe) : Dataframe of the peak-to-peak time differences
    
    """
    time_diff_df = pd.DataFrame([])
    for participant in participants:
        data = sensor_data.loc(axis = 0)[participant,:,:,:]
        time_stamps = get_ecg_peaks(data)
        d = data.loc(axis = 0)[participant,:,:,time_stamps]

        #Computing time differences
        try:
            d['time_differences'] = np.concatenate([np.diff(time_stamps)/np.timedelta64(1,'ms'), [0]])
        except:
            d['time_differences'] = np.concatenate([np.diff(time_stamps)/np.timedelta64(1,'ms'), [0,0]])

        df = d[['time_differences']]

        #Taking out time differences that is more than the upper bound and less than the lower bound
        diff_mean = np.mean(df.time_differences)
        upper_threshold = 1200          # diff_mean + (4*np.std(df.time_differences))
        lower_threshold = 400          # diff_mean - (4*np.std(df.time_differences))
        df = df[(df.time_differences<upper_threshold) & (df.time_differences>lower_threshold)]

        # Drop NaN contexts
        temp = df.reset_index("context")
        temp = temp[pd.notnull(temp['context'])]
        df = temp.reset_index().set_index(["Participant","type","context"])
        time_diff_df = pd.concat([time_diff_df, df])
        
    return time_diff_df


def get_hr_features(time_diff_df):
    """
    Computes heart rate from ECG signals
    
    Input:
        time_diff_df (dataframe): Dataframe of peak-to-peak time differences
        
    Output:
        ecg_hr_features (dataframe) : Dataframe of participants with their heart rate
    
    """
    print("\n Computing Heart Rate Features....")
    ecg_hr_features = time_diff_df.groupby(["Participant","type","context"], 
                                        sort = True).mean()
    ecg_hr_features['ecg_heart_rate'] = (60/ecg_hr_features['time_differences'])*1000
    ecg_hr_features.drop("time_differences",axis = 1, inplace = True)
    
    return ecg_hr_features


def get_hrv_features(time_diff_df):
    """
    Computes heart rate variability from ECG signals
    
    Input:
        time_diff_df (dataframe): Dataframe of peak-to-peak time differences
        
    Output:
        ecg_hrv_features (dataframe) : Dataframe of participants with their heart rate variability
    
    """
    print("\n Computing Heart Rate Variability Features....")
    ecg_hrv_features = time_diff_df.groupby(["Participant","type","context"], sort = True).std()
    ecg_hrv_features.rename(columns = {"time_differences":"ecg_hrv_std"}, inplace = True)
    
    return ecg_hrv_features


def get_ecg_features(sensor_data):
    """
    Computes the features from ECG signals. Uses :func: get_hr_features() and :func: get_hrv_features()
    
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        ecg_hr_features (dataframe) : Dataframe of participants' heart rate
        ecg_hrv_features (dataframe) : Dataframe of participants' heart rate variability
    
    """
    participants = sensor_data.index.get_level_values("Participant").unique()
    time_diff_df = get_time_diff(sensor_data, participants)
    ecg_hr_features = get_hr_features(time_diff_df)
    ecg_hrv_features = get_hrv_features(time_diff_df)
    
    return ecg_hr_features, ecg_hrv_features


def get_skin_temperature_features(sensor_data):
    """
    Computes skin temperature features. Mean skin temperature for every context (2mins)
    
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        skin_temperature (dataframe) : Dateframe of participants' skin temperature
    
    """
    print("\n Computing Skin temperature Features....")
    skin_temperature = sensor_data[['1-SKTA']]
    skin_temperature = skin_temperature.groupby(["Participant","type","context"]).mean()
    skin_temperature.rename(columns = {"1-SKTA":"skin_temperature"}, inplace = True)
    
    return skin_temperature


def get_eda_mean(sensor_data):
    """
    Computes the mean EDA of each participant for every context (2mins)
    
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        eda_mean (dataframe) : Dataframe of participants' mean EDA
    
    """
    print("\n Computing EDA Mean....")
    eda_mean = sensor_data[['EDA']]
    eda_mean = eda_mean.groupby(["Participant","type","context"]).mean()
    eda_mean.rename(columns = {"EDA":"eda_mean"}, inplace = True)
    
    return eda_mean

def get_eda_peaks(sensor_data):
    """
    Computes the number of SCR peaks of EDA signals. Uses :func: get_eda_features()
    
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        eda_peaks_df (dataframe) : Dataframe of participants' EDA peak count
    
    """
    print("\n Computing EDA number of peaks....")
    eda_peaks_df = pd.DataFrame([])
    participants = sensor_data.index.get_level_values("Participant").unique()
    for participant in participants:
        data = sensor_data.loc(axis = 0)[participant,:,:,:]
        d = data['EDA'].groupby(["Participant","type","context"]).apply(lambda x: get_eda_features(x))
        d = pd.DataFrame(d)
        eda_peaks_df = pd.concat([eda_peaks_df, d])
    eda_peaks_df.rename(columns = {"EDA":"eda_no_of_peaks"}, inplace = True)
    eda_peaks_df
    
    return eda_peaks_df

    
def get_eda_features(eda):
    """
    Uses the neurokit package to compute for the EDA number of peaks.
    
    Input:
        eda (list) : List of EDA signal
    Output:
        peaks (int) : EDA peaks count
    
    """
    
    if len(eda > 15):
        try:
            features = nk.eda_process(eda = eda, sampling_rate = 250)
        except:
            return 0
    else:
        return 0
    peaks = len(features['EDA']['SCR_Peaks_Indexes'])
    return peaks

def compute_power_spectra(signal, band):
    """
    Performs fast fourier transform on the EDA signals to get the high frequency and low frequency spectrum.
    
    Input:
        signal (array) : Array of EDA signal
        band (list) : list of upper frequency and lower frequency bound
    Output:
        power (int) : High frequency or low frequency power of the EDA signal
    
    """
    
    try:
        x = np.fft.fft(signal - np.nanmean(signal))
        x = np.abs(x)
        freq = np.fft.fftfreq(len(signal), d = 0.004)
    except:
        return 0
    low, high = np.array(band)
    vals = [i for i in x if high>i>low]
    idx = [list(x).index(i) for i in vals]

    frequencies = freq[idx]
    power = np.sum((frequencies/len(signal))**2)
    return power

def compute_frequency_band_power(signal, band, sampling_rate):
    """
    Computes the frequency band and takes only the frequencies that are within a specific range of frequencies.
    
    Input:
        signal (array) : Array of EDA signals
        band (list) : upper and lower bound of frequency band
        sampling_rate (int) : Sampling rate of signal
    Output:
        lfp (int) : low frequency power
        hfp (int) : high frequency power
        lfp/hfp ( int) : ratio of lowe and high frequency power
        
    """
    freq, power = ss.periodogram(signal - np.nanmean(signal), sampling_rate)
    low_f1, low_f2, high_f1, high_f2 = np.array(band)
    lfp_idx  = np.where((freq>=low_f1) & (freq>=low_f2))[0]
    hfp_idx  = np.where((freq>=high_f1) & (freq>=high_f2))[0] 
    lfp = np.trapz(power[lfp_idx], x = freq[lfp_idx])
    hfp = np.trapz(power[hfp_idx], x = freq[hfp_idx])
    
    return [lfp, hfp, lfp/hfp]

def get_eda_powers(sensor_data):
    """
    Computes EDA frequences using :fun: compute_frequency_band_power()
    
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        eda_powers (dataframe) : Dataframe of participants' with their EDA powers
    
    """
    
    print("\n Computing EDA Frequencies....")
    #High Frequecy and Low Frequency
    bands =  [0.045, 0.15, 0.15,0.25]
    eda_powers_df = pd.DataFrame([])
    participants = sensor_data.index.get_level_values("Participant").unique()
    for participant in participants:
        data = sensor_data.loc(axis = 0)[participant,:,:,:]
        eda_powers = data["EDA"].groupby(["Participant","type","context"]).\
                    apply(lambda x:compute_frequency_band_power(x,bands,250) if len(x)>1 else pd.Series(np.nan))
        eda_powers = pd.DataFrame(eda_powers)
        eda_powers = pd.DataFrame(list(eda_powers["EDA"].values), index = eda_powers.index, 
                                  columns = ["eda_lf","eda_hf","eda_lf_hf_ratio"])
        eda_powers_df = pd.concat([eda_powers_df, eda_powers])
    
    return eda_powers_df

def change_events(df):
    df = df.reset_index("context")
    df = df[df['context']!="FrontBuffer"]
    df = df[df['context']!="EndBuffer"]
    df = df[df['context']!="Garbage"]
    df = df.set_index("context", append = True)
    return df

def get_initial_times(sensor_data):
    """
    Takes the datetime of each context for future use"
        
    Input:
        sensor_data (dataframe) : Dataframe of participants' sensor data
    Output:
        temp (dataframe) : Dataframe of participant datetimes
   
    """
    
    cols = sensor_data.columns
    time_df = sensor_data.reset_index("Datetime")
    time_df = time_df.drop(cols, axis = 1)
    temp = time_df.reset_index("context")
    temp = temp[(temp["context"]!="Garbage") & (temp["context"]!="FrontBuffer") & (temp["context"]!="EndBuffer")]
    temp.set_index("context", append = True, inplace = True)
    t = temp.reset_index()
    t["Participant"] = t["Participant"].astype(int)
    temp = t.set_index(["Participant","type","context"])
    temp["Datetime"] = temp.groupby(["Participant","type","context"]).apply(lambda x: x["Datetime"][0])
    temp = temp.drop_duplicates()
    
    return temp
    
def feature_extraction(path):
    """
    Generates features from sensor signals.
    
    Input:
        path (string) : Path to the input sensor data
        output_path (string) : Parth to the output location
    Output:
        final_df (dataframe) : Dataframe containing the sensor derived features of all participants
    
    """
    sensor_data = joblib.load(path)
    sensor_data = change_context(sensor_data)
    ecg_hr_features, ecg_hrv_features = get_ecg_features(sensor_data)
    sensor_data = sensor_data.drop("peaks_flag", axis = 1)
    skin_temperature = get_skin_temperature_features(sensor_data)
    eda_mean = get_eda_mean(sensor_data)
    eda_no_of_peaks = get_eda_peaks(sensor_data)
    eda_powers = get_eda_powers(sensor_data)
    
    eda_features = eda_mean.merge(eda_no_of_peaks, how = 'left', right_index = True, left_index = True)
    eda_features = eda_features.merge(eda_powers, how = "left", right_index = True, left_index = True)
    
    features_dataframe = {"ecg_hr":ecg_hr_features, "ecg_std":ecg_hrv_features, "skt":skin_temperature, "eda":eda_features}
    
    all_features = pd.DataFrame([])
    flag= True
    
    for key, value in features_dataframe.items():
        features_dataframe[key] = change_events(value)
    
    
    #Merging of dataframes
    for key,value in features_dataframe.items():
        if flag:
            all_features = value
            flag = False
        else:
            all_features = all_features.merge(value, how = "left", right_index = True, left_index = True)
    print("\n Taking initial times...")        
    time_df = get_initial_times(sensor_data)
    
    #Merging the features with its original datetimes 
    print("\n Merging all features....")
    all_features.reset_index(inplace = True)
    all_features["Participant"] = all_features["Participant"].astype(int)
    all_features.set_index(["Participant","type","context"], inplace = True)
    final_df = all_features.join(time_df)
    final_df.set_index("Datetime", append = True, inplace = True)
    
    #Adding columns of context order and type index
    print("\n Adding other necessary columns")
    final_df.sort_index(axis = 0, level = "Datetime", inplace = True)
    final_df["Context_order"] = final_df.groupby(["Participant","type"]).cumcount()+1
    final_df.reset_index("type", inplace = True)
    final_df["Type_index"] = final_df["type"].apply(lambda x: 1 if x=="3D" else 0)
    final_df.reset_index(inplace = True)
    
#     print("\n Normalizing.....")
#     final_df = fd.get_distribution(final_df)
#     print("\n Saving....")
#     joblib.dump(final_df, output_path)
    
    return final_df

    

    