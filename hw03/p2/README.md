ECE 720 PPA Predictor Training Tutorial
(c) 2023-09-12 Luis Francisco, Donghyeon Koh, & W. Rhett Davis, 
               NC State University

This tutorial introduces the training of model for predicting power,
performance, and area (PPA) in digital integrated circuit design
flows.  For simplicity a model with only two objectives (area and
delay, i.e. performance) is trained, using data for synthesis only,
but the approach can be extended to more objectives and design-flow
stages.

## Quick-Start Instructions

    $ source setup.sh
    $ make train
    (Find the cross-validation split with the minimum error, 
     e.g. split 3)
    $ cp mymodel3.pt mymodel.pt
    $ make retrain 

## Improving Model Accuracy

Note that the "train" target executes the command "python3 train.py
500", where the last argument is the number of training epochs.  For
additional accuracy, you may execute the script multiple times.  The
models from previous runs will be loaded by default, and training will
continue for the number of epochs specified.  Note that the
train-loss#.png files will be overwritten with the loss-curves for
only the latest execution of the script (i.e. the loss-curves for
previous training epochs will be lost)

Note also that the "retrain" target executes the command "python3
retrain.py 500", which behaves much the same as the train.py script.
The primary difference is that the adapter models from previous runs
are loaded for additional training.  The base-model is loaded from the
file mymodel.pt and is not retrained (i.e. all parameters are fixed).

## Quick Model Evaluation

To evaluate a base-model or adapter without training, use "python3
train.py" or "python3 retrain.py" with no epochs argument.  The models
will be loaded, and error will be calculated.  No loss-curves are
generated in this mode.

