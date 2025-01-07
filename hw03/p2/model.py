import torch

class MyModel(torch.nn.Module):

    def __init__(self,in_dim=6,out_dim=1,layers=[128,256,512,256,64]):
        super(MyModel,self).__init__()
        self.in_dim = in_dim
        self.out_dim = out_dim
        self.layers = layers
        self.layers.append(self.out_dim)
        self.fcs = torch.nn.ModuleList()
        for i in range(len(self.layers)):
            if i==0:
                lyr=torch.nn.Linear(self.in_dim,self.layers[i],dtype=torch.double)
            else:
                lyr=torch.nn.Linear(self.layers[i-1],self.layers[i],dtype=torch.double)
            #torch.nn.init.xavier_uniform_(lyr.weight.data)
            self.fcs.append(lyr)
            
    def forward(self,x):
        # print(x)
        # print(f'0 x.shape {x.shape}')
        if len(self.layers)==1:
            x = self.fcs[0](x)
            # print(f'1 x.shape {x.shape}')
        else:
            x = torch.nn.functional.relu(self.fcs[0](x))
            # print(f'1 x.shape {x.shape}')
            for i in range(1, len(self.layers)-1):
                x = torch.nn.functional.relu(self.fcs[i](x))
                # print(f'{i+1} x.shape {x.shape}')
            x = self.fcs[-1](x)
            # print(f'{len(self.layers)} x.shape {x.shape}')
        return x

    def resetWeights(self):
        'Reset model weights during cross-validation to avoid weight leakage'
        for lyr in self.fcs:
            lyr.reset_parameters()

class Adapter(torch.nn.Module):

    def __init__(self,in_dim=6,out_dim=1,layers=[128,256,512,256,64],base_layers=[128,256,512,256,64]):
        super(Adapter,self).__init__()
        self.in_dim = in_dim
        self.out_dim = out_dim
        self.layers = layers
        self.layers.append(self.out_dim)
        self.base_layers = base_layers
        self.base_model = MyModel(self.in_dim,self.out_dim,self.base_layers)
        self.fcs = torch.nn.ModuleList()
        for i in range(len(self.layers)):
            if i==0:
                lyr=torch.nn.Linear(self.in_dim+self.out_dim,self.layers[i],dtype=torch.double)
            else:
                lyr=torch.nn.Linear(self.layers[i-1],self.layers[i],dtype=torch.double)
            #torch.nn.init.xavier_uniform_(lyr.weight.data)
            self.fcs.append(lyr)

    def forward(self,x):
        y = self.base_model(x)
        
        #print(x)
        # print(f'0 x.shape {x.shape}')
        if len(self.layers)==1:
            x = self.fcs[0](torch.hstack([x,y]))
            # print(f'1 x.shape {x.shape}')
        else:
            x = torch.nn.functional.relu(self.fcs[0](torch.hstack([x,y])))
            # print(f'1 x.shape {x.shape}')
            for i in range(1, len(self.layers)-1):
                x = torch.nn.functional.relu(self.fcs[i](x))
                # print(f'{i+1} x.shape {x.shape}')
            x = self.fcs[-1](x)
            # print(f'{len(self.layers)} x.shape {x.shape}')

        return x

    def resetWeights(self):
        '''
        Reset model weights during cross-validation to avoid weight leakage
        Don't reset base-model weights, because we assume that they are fixed.
        '''
        for lyr in self.fcs:
            lyr.reset_parameters()

#################################
# Scale and Shift adpater       #
# based on Low-Rank Adaptation  #
# := y = alpha*x + beta         #
#                               #
#################################

class ScaleandShiftAdapter(torch.nn.Module):
    def __init__(self,in_dim=4, out_dim=1,base_layers=[128,256,512,256,64]):
        super(ScaleandShiftAdapter, self).__init__()
        self.in_dim = in_dim
        self.out_dim = out_dim
        self.alpha = torch.nn.Parameter(torch.ones(out_dim))
        self.beta = torch.nn.Parameter(torch.ones(out_dim))
        self.base_layers = base_layers
        self.base_model = MyModel(self.in_dim,self.out_dim,self.base_layers)
        self.outLayer = torch.nn.Linear(self.out_dim, self.out_dim, dtype=torch.double)

    def forward(self,x):
        #print(f'x.shape = {x.shape}')
        y = self.base_model(x)      
        y_ssa = self.alpha * y + self.beta

        x_out = self.outLayer(y_ssa)
        return y_ssa


    def resetWeights(self):
        self.outLayer.reset_parameters()

