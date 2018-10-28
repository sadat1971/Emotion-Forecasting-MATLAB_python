# Emotion-Forecasting
The FG2019 paper submitted as Audio-Visual Emotion Forecasting. This repository contains the codes and other necessary information for that.


The work is explained in steps:

## Data Preparation and processing
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


## Building the Models

**Step 8: Running the FC-DNN:** The FC-DNN will have 3 FC layers and one softmax output layer at the end. FC-DNN has 
following criterias:
-RELU as activation
-ADAM with 0.0001 learning rate and 128 as batch size
-masking layer to prevent the 0's at the end
-selecting the stopping criteria by early stopping, when the cross validating recall  is not increased after 10 epochs
-Using leave-one-subject-Out and using 20% of the training data in each fold for choosing the number of epochs
-We use unweighted accuracy as performance measure.

> code: FC_DNN.py

**Step 9: Running the D-LSTM and D-BLSTM:** The D-LSTM will have two LSTM layers, one FC layer and one softmax output layer at the end. They have following criterias:
-RELU as activation
-ADAM with 0.0001 learning rate and 128 as batch size
-masking layer to prevent the 0's at the end
-selecting the stopping criteria by early stopping, when the cross validating recall  is not increased after 10 epochs
-Using leave-one-subject-Out and using 20% of the training data in each fold for choosing the number of epochs
-We use unweighted accuracy as performance measure

The same criterias are for D-BLSTM too.

> code: D_LSTM.py and D_BLSTM.py

## How to  Run

For running the codes, you need _MATLAB (any version after 7.0)_, _Python  (Any version after 3.0)_ with keras installed.
Download the the folder **Full_EF** and also put the **IEMOCAP_data** and **All_audiovisual** folders from >kimlab/Sadat/IEMOCAP_forcasting/Full_EF. 

a. For preaparing you desire dataset go to the **Full_EF** directory and run in matlab >MAIN_PROCESS(st, FW, history),

where for *st* stands for step size (1, 2 or 3), *FW* stands for Forecasting Window ('UF' or 'TF') , and *history* stands for presence or absence of history ('cur' or 'his').
For example, to prepare the dataset for TF-his 2, you have to write,
> MAIN_PROCESS(2, 'TF', 'his')

The description of function files are below:
**f_window()**: This code converts the framewise data to windowwise data.

**UF_preparing_cur(st)**: This code prepare data for the task of Utterance forecasting. At the end of the code, we will find a prepared dataset for utterance forecasting. The preparation includes normalization and zero padding at the end. It takes step size as input.

**UF_preparing_his(st)**: This code will take history for Utterance forecasting and prepare data for forecasting. This function has a dependendency and it is, we must run *UF_preparing_cur* first. It takes step size as input.

**create_TF_subsets_from_UF()**: This piece of code will calculate the time distance of utterance step forecasting and organize all of them in a manner that their time distance fall into a definite time-group.

**TF_preparing_cur(st)**: This function process the data from the subset of UF (which is saved time-distance wise or TF  1, 2 or 3). The processing includes making the statistical features and normalization. It takes step size as input.

**TF_preparing_his(st)**: This code will take history for Time forecasting and prepare data for forecasting. This function has a dependendency and it is, we must run *TF_preparing_cur* first. It takes step size as input.

**saving(st, FW, history)**: This code will save all the prepared and normalized data in a way that they can be used for running FC-DNN, D-LSTM and D-BLSTM network. It takes step size, forecasting window and history ('his' or 'cur') as input. The function returns the size of the data which will be used in *D_LSTM.py* and *D_BLSTM.py*. The variable returned will have following form:  >(utterance_number, window_size, 895). 


b. For running different models, the 3 codes are used. Go to the **Full_EF** directory and run :
- for FC-DNN 
> python FC_DNN.py
- for D-LSTM and D-BLSTM, open the *D_LSTN.py* file. In the variable name *utterances*, put down the utterance_number and *W_Length*,put down the window_size from the output of *saving* function. Then run,
> python D_LSTM.py

> python D_BLSTM.py


**FC_DNN.py**: This code will apply FC-DNN on your data

**D_LSTM.py**: This code will apply D-LSTM on your data

**D_LSTM.py**: This code will apply D-BLSTM on your data



