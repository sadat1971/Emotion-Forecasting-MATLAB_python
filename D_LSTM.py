#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 26 19:43:52 2018

This code will apply D-LSTM on your data

@author: sadat
"""
#specify the data size

utterances=2006  #change it  to your data size
W_Length=88  #change it to your window length

import numpy
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.metrics import accuracy_score
from sklearn.metrics import recall_score
#import matplotlib.pyplot as plt
from sklearn.model_selection import LeaveOneGroupOut
from keras.utils import np_utils
import keras    
from sklearn.metrics import confusion_matrix
from keras.callbacks import EarlyStopping
from keras.layers import Bidirectional
from keras.layers import Masking
from keras.layers import Dropout



logo = LeaveOneGroupOut()
grp = numpy.loadtxt('data_for_keras/speaker_group.csv', delimiter=",")
data=numpy.loadtxt('data_for_keras/data_forecast.csv',delimiter=",")
Y=numpy.loadtxt('data_for_keras/label_forecast.csv',delimiter=",")
A=data.reshape((utterances,W_Length,895))
#code for LSTM model
F2predict={} #saves the softmax output
F2test={} #saves the test set GTs
F2_modelpred={} #saves the final outputs
F2con={} #saves the confusion matrix per speaker
F2ACC={} #saves the accuracy per speaker
F2WR={} #saves the weighted accuracy per speaker
F2UWR={} #saves the unweighted recall per speaker
F2VAL_ACC={} #saves valence accuracies
F2TR_ACC={} #saves the training accuracies
F=0
for train, test in logo.split(A, Y, grp):
    label_train=np_utils.to_categorical(Y[train])
    # Set callback functions to early stop training and save the best model so far
    callbacks= [EarlyStopping(monitor='val_loss', patience=10)]    
    model = Sequential()
    model.add(Masking(mask_value=0., input_shape=(W_Length, 895)))
    model.add(Bidirectional(LSTM(128,return_sequences=True)))
    model.add(Dropout(0.5))
    model.add(Bidirectional(LSTM(128)))
    model.add(Dropout(0.5))
    model.add(Dense(256,activation='relu'))
    model.add(Dropout(0.5))##
    model.add(Dense(4, activation='softmax'))
    adam=keras.optimizers.Adam(lr=0.0001, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0, amsgrad=False)   
    sgd=keras.optimizers.SGD(lr=0.001, momentum=0.0, decay=0.0, nesterov=False)
    adagrad=keras.optimizers.Adagrad(lr=0.01, epsilon=None, decay=0.0)
    model.compile(loss='categorical_crossentropy', optimizer=adam, metrics=['accuracy'])
    history=model.fit(A[train], label_train,  epochs=50, validation_split=0.20, callbacks=callbacks, batch_size=128, verbose=1)
    X_pred=model.predict(A[test,:])
    F2predict[F]=X_pred
    F2test[F]=Y[test]
    Y_pred=numpy.argmax(X_pred, axis=1)
    F2VAL_ACC[F]=history.history['val_acc']
    F2TR_ACC[F]=history.history['acc']
    F2con[F]=confusion_matrix(Y[test],Y_pred)
    F2ACC[F]=accuracy_score(Y[test],Y_pred)
    F2WR[F]=recall_score(Y[test],Y_pred, average='weighted') 
    F2UWR[F]=recall_score(Y[test],Y_pred, average='macro') 
    F2predict[F]=X_pred
    F2test[F]=Y[test]
    F2_modelpred[F]=Y_pred
    print(F2con[F])
    print(F2UWR[F])
    print('score of F is {0}'.format(F))
    F2_modelpred[F]=Y_pred
    #model.save('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/1_group/Results/BLSTM/Saved_Models/M_{}/m_model_sp_{}.h5'.format(cs, F))
    F=F+1
    