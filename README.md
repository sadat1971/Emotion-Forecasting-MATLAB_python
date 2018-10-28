# Emotion-Forecasting
The FG2019 paper submitted as Audio-Visual Emotion Forecasting. This repository contains the codes and other necessary information for that.


The work is explained in steps:

**Step 1. Feature Extraction:**
Audio: MFB(27), MFCC(12), Pitch, Energy
Video: Facial Markers: 46 facial markers (3-d)
```test_CHI = TT(:, 1:9);
       test_FH = TT(:,10:18);
       test_CHK = TT(:,19:66);
       test_BM = TT(:,88:111);
       test_BRO = TT(:,112:135);
       test_MOU = TT(:,136:159);
CHI: chin, FH: forehead, CHK: cheek, BM: upper eyebrow, BRO: eyebrow, MOU: mouth
Feature Extraction at 25 ms framerate and 50 ms window.
```

**Step 2. Removal of NaNs**: For the NaN features, we have used linear interpolation. If the NaN values of an utterance is more than 30%, we have removed that utterance. 
> code: gather_all_AV.m

**Step 3. Windowing of the frames**: Then we do the windowing. 30 frames, with 50% overlap, using 5 statistical features-- means, std, first-quantile, third-quantile and interquartile range. In total, there will be 895 features (41 audio+138 video= 179 and 5 statistical 179X5=895 features)
> code: f_window.m 

**Step 4: Preparing and Normalizing data for Utterance Forecasting (UF)**: For forecasting, we prepare the data. The preparation is tricky. Things we have to keep in mind-
- Forecasting uses current data and label for the next utterance(UF-1), or one after the next utterance (UF-2), or two after the next utterance (UF-3).
- You must use data and label from the same speaker
- You must forecast within a dialog. Therferefore the last utterance of the dialog needs to be discarded.
Now, while doing the history-added forecasting (UF-his), we need to be careful in adding previous utterance history. The first utterance of a dialog will not have any history utterance. 
We take emotions 0-3 categorical labels only. After the reformation of the data, we will z-normalize the data. Followed by that, we will do the zero padding at the end of the features of speakers that has length less than the longest utterance.

> code: UF_prparing_cur.m (for UF-cur) and UF_preaparing_his (for UF-his)


**Step 5: Creating subset of data for Time Forecasting (TF)**: In TF, first we take all the utterance step forecasting data (UF-1,2 ,3), find the time distance of forecasting in them and then regroup them depending on the time-distance of forecasting. We will use the time range of:
1<=time_distance<5
5<=time_distance<10
10<=time_distance<15

The 3 time groups data are saved.
> code: create_TF_subsets_from_UF.m

**Step 6: Preparing and Normalizing data for Time Forecasting (UF)**: Similar as step 4
> code: TF_prparing_cur.m (for TF-cur) and TF_preaparing_his (for TF-his)

**Step 7: Saving the data for running the models**: The data are saved in CSV format for DNN, D-LSTM and D-BLSTM operation.
>code: saving.m

-  We will use keras library with python for LSTM and BLSTM operation. Therefore, the data needs to be reshaped and saved likewise. 
code: save_all_1_step.m 


This way all UF-1, UF-2 and UF-3 are processed and saved

_Next, we process the data time-groupwise._ 


5.0. In the window of time-gap, we first take all the utterance step forecastinfg data (1 step, 2 step and 3 step), find the time distance of forecasting in them and then regroup them. We will use the time range of:
1<=time_distance<5
5<=time_distance<10
10<=time_distance<15

The 3 time groups data are saved and following the same process of UF, they are prepared and normalized and saved for analysis.

code: find_delay.m

_Next, we process the data for history-added forecasting._

6.0. Just while processing, we add the previous utterance with the current utterance. Notedly, there cannot be previous data for all utterance case. For the first utterance of a dialog, we willnot find the 'history' or previous utterance. The rest of the process is all the same. 

code: history_prepare_data_all.m

7.  Then we do the leave one out CV for D-LSTM and D-BLSTM. Keras library is used for this purpose. we select the following configurations:
_2 LSTM layers, 1 FC layers and 1 softmax output layer_
_RELU as activation_
_ADAM with 0.0001 learning rate and 128 as batch size_
_masking layer to prevent the 0's at the end_
_selecting the stopping criteria by early stopping, when the cross validating recall  is not increased after 10 epochs_


code: group_2_stat.ipynb 
