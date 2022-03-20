import numpy as np
import pandas as pd
import operator

from scipy import stats

def get_distribution(features):
    """
    Takes the distribution closest to the normal distribution. Takes into account the original feature values, 
    its square root, and its log.
    
    Input:
        features (dataframe) : Dataframe of particpants's sensor derived features
    Output:
        features (dataframe) : Dataframe containing features closest to the normal distribution.
    
    """
    print("\n Normalizing....")
    features = features.set_index(["Participant","type","context","Datetime"])
    sensor_features = features.columns[:-4]
    for sensor_feature in sensor_features:
        result = check_normality(features[sensor_feature])
        features[sensor_feature] = result
    features.reset_index(inplace = True)
    features.rename(columns = {"type" : "Type", "context" : "Context"}, inplace = True)
    features.drop("Datetime",axis = 1, inplace = True)
    return features   
        
def check_normality(values):
    """
    Computes normality of the distribution of features using scipy's normaltest(). 
    Takes the distribution with the smallest p_value. In other words, the distribution closest to the normal distribution.
    
    Input:
        values (series) : Series of sensor derived feature values.
    Output:
        dist (array) : array of sensor derived feature's optimal distribution
    
    """
    
    log_values =  np.log(values)
    sqrts = np.sqrt(values)
    k, p_value = stats.normaltest(values)
    k, lp_value = stats.normaltest(log_values)
    k, sp_value = stats.normaltest(sqrts)

    values_dict = {"orig":values, "log": log_values, "sqrt":sqrts}
    p_values = {"orig":p_value, "log": lp_value, "sqrt":sp_value}
        
    max_val = max(p_values.items(), key=operator.itemgetter(1))[0]
    dist = values_dict[max_val]
    return  dist

