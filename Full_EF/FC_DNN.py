#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 26 19:43:52 2018

This code will apply FC-DNN on your data

@author: sadat
last updated: 27-10-2018
"""
#specify the data size

utterances=2006  #change it  to your data size

import numpy
from keras.models import Sequential
from keras.layers import Dense
from sklearn.metrics import accuracy_score
from sklearn.metrics import recall_score
#import matplotlib.pyplot as plt
from sklearn.model_selection import LeaveOneGroupOut
from keras.utils import np_utils
import keras    
from sklearn.metrics import confusion_matrix
from keras.callbacks import EarlyStopping
from keras.layers import Dropout



logo = LeaveOneGroupOut()
X = numpy.loadtxt("data_for_keras/FC_forecast.csv", delimiter=",")
Y_int=numpy.loadtxt("data_for_keras/label_forecast.csv", delimiter=",")
logo = LeaveOneGroupOut()
grp=numpy.loadtxt("data_for_keras/speaker_group.csv", delimiter=",")

F2con={} #save the confusion matrix in each speaker case
F2ACC={} #save the accuracy in each speaker case
F2WR={} #save the weighted accuracy in each speaker case
F2UWR={} ##save the Unweighted Accuracy in each speaker case
F=0
for train, test in logo.split(X, Y_int, grp):
    
    callbacks = [EarlyStopping(monitor='val_loss', patience=10)]
      # create model
    F2model = Sequential()
    F2model.add(Dense(256, input_dim=895, activation='relu'))
    F2model.add(Dropout(0.5))
    F2model.add(Dense(256))
    F2model.add(Dropout(0.5))
    F2model.add(Dense(256))    
    F2model.add(Dense(4, activation='softmax'))
    # Compile model
    ADAM=keras.optimizers.Adam(lr=0.0001, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0, amsgrad=False)
    F2model.compile(loss='categorical_crossentropy', optimizer='ADAM', metrics=['accuracy'])
    Y = np_utils.to_categorical(Y_int[train])
    history=F2model.fit(X[train], Y, epochs=50,validation_split=0.2 ,callbacks=callbacks, batch_size=128, verbose=1)
    len(history.history['loss'])
    X_pred=F2model.predict(X[test,:])
    Y_pred=numpy.argmax(X_pred, axis=1)
    F2con[F]=confusion_matrix(Y_int[test],Y_pred)
    F2ACC[F]=accuracy_score(Y_int[test],Y_pred)
    F2WR[F]=recall_score(Y_int[test],Y_pred, average='weighted') 
    F2UWR[F]=recall_score(Y_int[test],Y_pred, average='macro') 
    F=F+1
    
    print(history.history.keys())

