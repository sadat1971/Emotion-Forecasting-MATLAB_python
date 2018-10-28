%% This code will save all the prepared and normalized data in a way that they can be used for running FC-DNN, D-LSTM and D-BLSTM network
% Input: st (1,2,3)
%        FW ('UF', 'TF')
%        history ('his' or 'cur')


% Created By: 
%           Sadat Shahriar
%           last modified: 10-27-2018

% Usage:  dimension=savings(2,'TF', 'cur')  
% the output variable will give you the dimension of the data. All the data has 895 features
function S= saving(st, FW, history)
mkdir data_for_keras
sprintf('we start saving the for running the operation in keras. The files are saved in CSV format');
speaker_amount=[];  %Will save the amount of data for each speaker
All_data=[]; %Save the data portion only after reshaping. Not the labels
LABELS=[]; %Will save the labels only
i=1;
for sp=1:10
    if strcmp(FW, 'UF')
    load(sprintf('temp_data/step%d_normalized_s_%d.mat',st,sp));
    elseif strcmp(FW, 'TF')
    load(sprintf('TF_data/step%d_normalized_s_%d.mat',st,sp));    
    else
        sprintf('please write either UF or TF in the FW field')
    end
    speaker_amount=[speaker_amount;size(normalized_semi,2)];
    
    for u=1:size(normalized_semi,2)
        
        All_Data(i,:,:)=transpose(normalized_semi(u).data);  %The All_Data is saved the data in 3 dimensions. The first dimension indicates
        %the data/utterance index. The remaining the dimensions are row and
        %columns.
        LABELS=[LABELS;normalized_semi(u).label];
        i=i+1;
        
    end
    sprintf('data is reshaped for LSTM and BLSTM network upto speaker %d',sp)    
    
    
end

csvwrite('data_for_keras/data_forecast.csv',All_Data);
csvwrite('data_for_keras/label_forecast.csv',LABELS);
r=1;
speaker_id=[];  % It is necessary for letting the program know, which data is of which speaker
for i=1:10
    
    speaker_id(r:r+speaker_amount(i)-1,1)=i;
    r=r+speaker_amount(i);
end
csvwrite('data_for_keras/speaker_group.csv',speaker_id)    
    
%% Save the FC data if that is history-less or current forecasting
if strcmp(history, 'cur')
    if strcmp(FW, 'UF')
        load('temp_data/FC_forecast.mat');
    elseif strcmp(FW, 'TF')
        load('TF_data/FC_forecast.mat');
    else
        sprintf('please write either UF or TF in the FW field')
    end
    
    
    csvwrite('data_for_keras/FC_forecast.csv',NN)
end


S=size(All_Data)
save('data_for_keras/speakerUtterance_amount.mat','speaker_amount')

end
