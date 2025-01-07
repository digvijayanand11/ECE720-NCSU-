import os, sys
from dataset import CAEMLPPADataset
from model import MyModel, Adapter, ScaleandShiftAdapter
import torch
from torch.utils.data import random_split
import matplotlib.pyplot as plt
from sklearn.model_selection import ShuffleSplit
import numpy as np


# First     argument gives the number of training epochs
# Second    argument gives the number of dataset samples
# Third     argument gives the percentage of test dataset

if len(sys.argv)>1:
    epochs = int(sys.argv[1])
    num_samples = int(sys.argv[2])
    test_size = float(sys.argv[3])
else:
    epochs = 0
    num_samples = 0
    test_size = 0
if epochs > 0:
    print(f"Re-training for \t\t\t{epochs} epochs")
if num_samples > 0:
    print(f"====== Total dataset size \t{num_samples} samples")
if test_size > 0:
    print(f"====== Test size is \t\t{test_size*100}% \t\t= {num_samples*test_size} samples")


# Get cpu or gpu device for training
device = "cuda" if torch.cuda.is_available() else "cpu"
print("Using {} device".format(device))

random_seed=0
crossvalIter = ShuffleSplit(n_splits=50, test_size=test_size, random_state=random_seed)
torch.manual_seed(random_seed)

# Load Dataset
# fullDS=CAEMLPPADataset(design='rocket_tiny')

fullDS=CAEMLPPADataset(design='cnn', num_samples=num_samples)
crossvalDS=fullDS
# Split the full dataset into a test set and cross-validation set, if needed.
# crossvalDS,testDS = random_split(fullDS,[data_lengths['train']+data_lengths['valid'],data_lengths['test']])
# If no test set is needed, use the full set for cross validation.
crossvalDS=fullDS
testDS=[]

# Initialize the data-lengths (i.e. number of samples in each set)
# These are needed to calculate loss over each sample set, 
# rather than each mini-batch.  
split = list(crossvalIter.split(crossvalDS)) 
data_lengths = { 'train':len(split[0][0]), 'valid':len(split[0][1]), 'test':len(testDS) }
print(f"Data split: training {data_lengths['train']} validation {data_lengths['valid']} test {data_lengths['test']}")


def confidencePercentile(data,target):
    '''Usage: value, fraction = confidencePercentile(data,target), 
    where [data] is the set of values 
    and [target] is the percentile target (between 0 and 1)
    Interpret the results as "[fraction] of the data is less than [value]"
    where [fraction] is between 0 and 1'''
    d,index=torch.sort(data.t()[0])
    increment=1/len(d)
    index=min(int(target/increment),len(d)-1)
    return d[index],index*increment

def train(dataloader, model, loss_fn, optimizer, phase):
    running_loss = 0.0
    if phase == 'train':
        model.train()
    else:
        model.eval()
    for x, y in dataloader:
        #print(f'{x.shape[0]} {y.shape[0]}')
        x, y = x.to(device), y.to(device)

        # Compute prediction error
        pred = model(x)
        loss = loss_fn(pred, y)
        running_loss += loss.item() * x.shape[0]

        # Backpropagation
        optimizer.zero_grad()
        if phase == 'train':
            loss.backward()
            optimizer.step()

    #print(f"{phase} loss: nMSE {running_loss/data_lengths[phase]:>8f}")
    return running_loss/data_lengths[phase]

def test(dataloader, model, loss_fn):
    model.eval()
    actualNorm=torch.Tensor()
    predictionNorm=torch.Tensor()
    actualDenorm=torch.Tensor()
    predictionDenorm=torch.Tensor()
    with torch.no_grad():
        for x, y in dataloader:
            x, y = x.to(device), y.to(device)
            pred = model(x)
            actualNorm=torch.cat([actualNorm.to(device),y])
            predictionNorm=torch.cat([predictionNorm.to(device),pred])
            actualDenorm=torch.cat([actualDenorm.to(device),fullDS.denormalizeTargets(y,x)])
            predictionDenorm=torch.cat([predictionDenorm.to(device),fullDS.denormalizeTargets(pred,x)])
    test_loss = np.log10(loss_fn(predictionNorm, actualNorm).item())
    absPctErr=torch.abs((actualDenorm-predictionDenorm)/actualDenorm)
    mapeScore = torch.mean(absPctErr)
    ape05Conf, pct = confidencePercentile(absPctErr,0.05)
    ape95Conf, pct = confidencePercentile(absPctErr,0.95)
    return test_loss, mapeScore, ape05Conf, ape95Conf

trainLossList=[]
validLossList=[]
mapeScoreList=[]
ape95ConfList=[]
ape05ConfList=[]

for split, (trainID,validID) in enumerate(crossvalIter.split(crossvalDS)):
    # Initialize subset samplers
    trainSS = torch.utils.data.SubsetRandomSampler(trainID)
    validSS = torch.utils.data.SubsetRandomSampler(validID)

    # Initialize Data Loaders
    batchSize=64
    trainDL=torch.utils.data.DataLoader(crossvalDS,batch_size=batchSize,sampler=trainSS)
    validDL=torch.utils.data.DataLoader(crossvalDS,batch_size=batchSize,sampler=validSS)
    testDL=torch.utils.data.DataLoader(testDS,batch_size=batchSize)

    # Initialize Model
    #model = Adapter(in_dim=len(fullDS.features),out_dim=len(fullDS.targets),layers=[64],base_layers=[64]).to(device)

    model = ScaleandShiftAdapter(in_dim=len(fullDS.features),out_dim=len(fullDS.targets),base_layers=[64]).to(device)
#   print(model)

    model.resetWeights()
    if os.access(f'myadapter{split}.pt',os.F_OK):
        model.load_state_dict(torch.load(f'myadapter{split}.pt'))
        for param in model.base_model.parameters():
            param.requires_grad = False
    elif os.access('mymodel.pt',os.F_OK):
        model.base_model.load_state_dict(torch.load('mymodel.pt'))
        for param in model.base_model.parameters():
            param.requires_grad = False
    model.eval()
    # print(model)

    # Choose loss function and optimizer
    loss_fn = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(filter(lambda p: p.requires_grad, model.parameters()),lr=1e-3)
    scheduler = torch.optim.lr_scheduler.StepLR(optimizer,step_size=50,gamma=0.7,verbose=False)

    if epochs > 0:
        train_loss = []
        valid_loss = []
        saved_model_epoch = 0
        for t in range(epochs):
            # print(f"Epoch {t+1}")
            tloss=train(trainDL, model, loss_fn, optimizer, 'train')
            train_loss.append(tloss)
            vloss=train(validDL, model, loss_fn, optimizer, 'valid')
            valid_loss.append(vloss)
            scheduler.step()
            if t==epochs-1:          # Use this line to save the last epoch's model
                torch.save(model.state_dict(),f'myadapter{split}.pt')
                saved_model_epoch = t+1
                saved_train_loss = tloss
                saved_valid_loss = vloss


        model.load_state_dict(torch.load(f'myadapter{split}.pt'))
        test_loss, mapeScore, ape05Conf, ape95Conf = test(validDL, model, loss_fn)
        print(f"Split {split} TL/VL {saved_train_loss/saved_valid_loss:.4e} Test loss: log nMSE {test_loss:>4f} dnMAPE {mapeScore:>8f} 5%-95% confidence {ape05Conf:>8f} - {ape95Conf:>8f} ")
        trainLossList.append(saved_train_loss)
        validLossList.append(saved_valid_loss)
        mapeScoreList.append(mapeScore.cpu())
        ape05ConfList.append(ape05Conf.cpu())
        ape95ConfList.append(ape95Conf.cpu())

        # print("Done!")
        # Plot loss
        line=[]
        legend=[]
        plt.figure()
        line.append(plt.plot(np.log10(train_loss))[0])
        legend.append('training')
        line.append(plt.plot(np.log10(valid_loss))[0])
        legend.append('validation')
        line.append(plt.plot(saved_model_epoch,test_loss,'rx')[0])
        legend.append('test')
        plt.legend(line,legend)
        plt.xlabel('epoch')
        plt.ylabel('loss (log nMSE)')
        plt.title(f'Split {split} Test loss: log nMSE {test_loss:>4f} dnMAPE {mapeScore:>8f}')
        plt.savefig(f'retrain-loss{split}.png')
        plt.close()

    else:
        # If no training epochs were given, then simply re-run the final evaluation
        test_loss, mapeScore, ape05Conf, ape95Conf = test(validDL, model, loss_fn)
        print(f"Split {split} Test loss: log nMSE {test_loss:>4f} dnMAPE {mapeScore:>8f} 5%-95% confidence {ape05Conf:>8f} - {ape95Conf:>8f} ")
        mapeScoreList.append(mapeScore.cpu())
        ape05ConfList.append(ape05Conf.cpu())
        ape95ConfList.append(ape95Conf.cpu())


meanMAPE=np.mean(mapeScoreList)
meanAPE05Conf=np.mean(ape05ConfList)
meanAPE95Conf=np.mean(ape95ConfList)
print(f"Overall dnMAPE mean {meanMAPE:>8f} 5%-95% confidence mean {meanAPE05Conf:>8f} - {meanAPE95Conf:>8f} ")
if len(trainLossList)>0:
    meanTLVLR=np.mean(np.array(trainLossList)/np.array(validLossList))
    print(f"Overall mean TL/VL {meanTLVLR:.4e}")

# Plot APE
bins = np.linspace(min(ape05ConfList),max(ape95ConfList),30)
plt.figure()
plt.hist(np.array(mapeScoreList),bins,alpha = 0.5,label='MAPE')
plt.hist(np.array(ape05ConfList),bins,alpha = 0.5,label='5% APE')
plt.hist(np.array(ape95ConfList),bins,alpha = 0.5,label='95% APE')
plt.axvline(meanMAPE, color='k', linestyle='dashed', linewidth=1, label='Mean')
plt.legend(loc='upper right')
plt.xlabel('APE')
plt.savefig('adapter-error-summary.png',bbox_inches='tight')
# plt.show()
plt.close()


os.system('date +%s > retrain')

# Verify that base model parameters didn't change
# origmodel = MyModel(in_dim=len(fullDS.features),out_dim=len(fullDS.targets),layers=[64]).to(device)
# if os.access('mymodel.pt',os.F_OK):
#     origmodel.load_state_dict(torch.load('mymodel.pt'))
#     # for param in origmodel.parameters():
#     #     param.requires_grad = False
# param=list(model.base_model.parameters())
# origparam=list(origmodel.parameters())
# for i in range(len(param)):
#   print(f'Equal? {param[i]==origparam[i]}')fullDS=CAEMLPPADataset(design='rocket_tiny')
