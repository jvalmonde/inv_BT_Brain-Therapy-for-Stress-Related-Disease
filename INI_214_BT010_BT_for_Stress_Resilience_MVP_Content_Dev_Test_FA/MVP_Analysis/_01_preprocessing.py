import os
import pandas as pd
from datetime import datetime, timedelta
import re


def load_data(path_to_raw):
    
    """
    PARAMETERS:
    -----------------
    path_to_raw: path to sensor data, point to the directory that 
                contains the individual participant directories
    
    RETURNS:
    -----------------
    merged_data: dictionary of dataframes containing the raw sensor
                data and the contexts of individual participants
    
    """
    directories = os.listdir(path_to_raw)
    merged_data = {}
    for directory in directories:
        pid_path = os.path.join(path_to_raw, directory)
        file_path = 'BT-MVP-WM-'+directory[-4:]+'-Biopac.csv.txt'
        sensor_data = pd.read_csv(os.path.join(pid_path, file_path),\
           skiprows=15, usecols=[0,1,2,3,4,5], names=['Time','RSP','PPG','1-SKTA','ECG','EDA'])
        json_files = [file for file in os.listdir(pid_path) if file.endswith(".json")]
        participant_event_data = pd.DataFrame([])
        # the json files contain the event logs
        # proceeding loop creates a dataframe for a participant's event data
        for json_file in json_files:
            parsed_event =  pd.read_json(os.path.join(pid_path, json_file))
            parsed_event = parsed_event[parsed_event['eventName']=='Script Log Event']['details']
            contexts = [[x['context'], x['time']] for x in parsed_event]
            event_data = pd.DataFrame(contexts, columns=['context','Datetime'])
            event_data['type'] = "3D" if "3D" in json_file else "2D"
            event_data['participant'] = directory[-4:]
            event_data = event_data.set_index(['participant','type'])
            participant_event_data = pd.concat([participant_event_data, event_data])
            
        participant_event_data['Datetime'] = pd.to_datetime(participant_event_data['Datetime'], unit = 's')
        participant_event_data['Datetime'] = participant_event_data['Datetime']-timedelta(hours = 5)
        event_date = participant_event_data.loc(axis=0)[participant_event_data.index.get_level_values(\
                                        'participant')==directory[-4:]].iloc[0]['Datetime'].date()
        
        sensor_data['Datetime'] = sensor_data['Time'].apply(lambda x:\
                                        datetime.combine(event_date, datetime.min.time()) + timedelta(seconds=x))
        
        sensor_data.drop(columns=['Time'])
        sensor_data = sensor_data[['Datetime','RSP','PPG','1-SKTA','ECG','EDA']]
        sensor_data = sensor_data.set_index(['Datetime'])
        participant_event_data = participant_event_data.reset_index().set_index(['Datetime'])
        merged_data[directory[-4:]] = (participant_event_data.merge(sensor_data,\
                                        how='outer', right_index=True, left_index=True))
        merged_data[directory[-4:]] = merged_data[directory[-4:]].fillna(method='ffill')
        merged_data[directory[-4:]] = merged_data[directory[-4:]][merged_data[directory[-4:]]['context'].str.\
                                                    contains("Buffer") == False]
        merged_data[directory[-4:]]['context'] = merged_data[directory[-4:]]['context'].apply(lambda x: x[-2:])
        
    return merged_data.reset_index()