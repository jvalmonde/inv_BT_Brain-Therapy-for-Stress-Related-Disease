#! /usr/bin/env python

import os
import sys
import subprocess
import joblib
import _02_feature_extraction as feature_extraction
import _03_feature_distribution as feature_distribution

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("""
        
            Please provide the path to the signal and the output location
            
            i.e.
            
            MVP_Analysis/run_project.py MVP_Analysis/data/signals.pkl MVP_Analysis/data/
            
            
            """)
        exit(0)
        
    base_path, output_path = sys.argv[1:3]
    
#     features = feature_extraction.feature_extraction(base_path)
#     joblib.dump(features, output_path+"features.pkl")
    features = joblib.load(output_path+"features.pkl")
    normalized_features = feature_distribution.get_distribution(features)
    normalized_features.to_csv(output_path+"data.csv", index = False)
