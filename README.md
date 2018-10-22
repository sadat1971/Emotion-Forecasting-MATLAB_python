# Emotion-Forecasting
The FG2019 paper submitted as Audio-Visual Emotion Forecasting. This repository contains the codes and other necessary information for that.


The work is explained in steps:

1. Feature Extraction:
Audio: MFB(27), MFCC(12), Pitch, Energy
Video: Facial Markers: 46 facial markers (3-d)
test_CHI = TT(:, 1:9);
       test_FH = TT(:,10:18);
       test_CHK = TT(:,19:66);
       test_BM = TT(:,88:111);
       test_BRO = TT(:,112:135);
       test_MOU = TT(:,136:159);
CHI: chin, FH: forehead, CHK: cheek, BM: upper eyebrow, BRO: eyebrow, MOU: mouth
Feature Extraction at 25 ms framerate and 50 ms window.


2. For the NaN features, we have used linear interpolation. If the NaN values of an utterance is more than 30%, we have removed that utterance. 
code: gather_all_AV.m
3. Then we do the windowing. 30 frames, with 50% overlap, using 5 statistical features-- means, std, first-quantile, third-quantile and interquartile range. In total, there will be 895 features (41 audio+138 video= 179 and 5 statistical 179X5=895 features)
code: Windowing.m

4.1.  Utterance Forecasting (UF) preparation of the data:  Then for forecasting, we prepare the data. The preparation is tricky. Things we have to keep in mind-
a. Forecasting uses current data and label for the next utterance.
b. You must use data and label from the same speaker
c. You must forecast within a dialog. Therferefore the last utterance of the dialog needs to be discarded. 

We take emotions 0-3 categorical labels only. After the reformation of the data, we will z-normalize the data. Followed by that, we will do the zero padding at the end of the features of speakers that has length less than the longest utterance.

code: preparing-1_step.m

4.2.  We will use keras library with python for LSTM and BLSTM operation. Therefore, the data needs to be reshaped and saved likewise. 
code: save_all_1_step.m 
