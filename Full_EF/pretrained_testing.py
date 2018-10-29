# -*- coding: utf-8 -*-
"""
Spyder Editor

This code will load the pretrained model and find the accuracies"""

# load the libraries
import numpy
from sklearn.metrics import accuracy_score
from sklearn.metrics import recall_score
from keras.utils import np_utils
import keras    
from sklearn.metrics import confusion_matrix
from keras.models import load_model

F2predict={}
F2test={}
F2con={}
F2ACC={}
F2WR={}
F2test={}
F2_modelpred={}
F2UWR={}

F=0

logo = LeaveOneGroupOut()
grp = numpy.loadtxt("Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/1_group/CSV/speaker_group.csv", delimiter=",")
data=numpy.loadtxt('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/1_group/CSV/time_data_1_step_forecast.csv',delimiter=",")
Y=numpy.loadtxt('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/1_group/CSV/label_1_step_forecast.csv',delimiter=",")
A=data.reshape((2006,26,895))

F=0
for train, test in logo.split(A, Y, grp):
    model = load_model('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/1_group/Results/BLSTM/Saved_Models/Models/m_model_sp_{0}.h5'.format(F))
    label_train=np_utils.to_categorical(Y[train])
    X_pred=model.predict(A[test,:])
    F2predict[F]=X_pred
    F2test[F]=Y[test]
    Y_pred=numpy.argmax(X_pred, axis=1)
    F2con[F]=confusion_matrix(Y[test],Y_pred)
    F2ACC[F]=accuracy_score(Y[test],Y_pred)
    F2WR[F]=recall_score(Y[test],Y_pred, average='weighted') 
    F2UWR[F]=recall_score(Y[test],Y_pred, average='macro') 
    F2test[F]=Y[test]
    F2_modelpred[F]=Y_pred
    print(F2con[F])
    print(F2UWR[F])
    print('score of F is {0}'.format(F))
    F2_modelpred[F]=Y_pred
    F=F+1