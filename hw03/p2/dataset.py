
import pandas as pd
import torch
from torch.utils.data import Dataset
import numpy as np

SCALE_FACTORS = { 'Tclk':10000.0, 'MaxTran':500.0, 'Uncertainty':200.0, 'Fanout':50.0,
                  'Area':50000.0, 'Cpath':10000.0  }

class CAEMLPPADataset(Dataset):
    def __init__(self,design='rocket', num_samples = 500):
        self.features = ['Tclk','MaxTran','Uncertainty','Fanout']
        self.targets = ['Area','Cpath']
        self.featuresData=np.array([])
        self.targetsData=np.array([])
        csvfile = "./data/"+design+".csv"
        pd_csv = pd.read_csv(csvfile,skiprows=1)
        data = pd_csv.values
        data = data[:num_samples]
        print(f'\n[design = {design}] [dataset size in dataset.py] Dataset size = {data.shape}')
        self.featuresData=data[:,1:5]
        for i in range(len(self.features)):
            self.featuresData[:,i]=self.featuresData[:,i]/SCALE_FACTORS[self.features[i]]
        self.targetsData=data[:,5:7]
        for i in range(len(self.targets)):
            self.targetsData[:,i]=self.targetsData[:,i]/SCALE_FACTORS[self.targets[i]]
    
    def __len__(self):
        return len(self.featuresData)

    def __getitem__(self,idx):
        return self.featuresData[idx],self.targetsData[idx]

    def denormalizeFeatures(self,data):
        #print(f'features type {type(data)} shape {data.shape}')
        for i in range(len(self.features)):
            data[:,i]=data[:,i]*SCALE_FACTORS[self.features[i]]
        return data

    def denormalizeTargets(self,data,x):
        # print(f'targets type {type(data)} shape {data.shape} x type {type(x)} shape {x.shape}')
        for i in range(len(self.targets)):
            data[:,i]=data[:,i]*SCALE_FACTORS[self.targets[i]]
        return data






