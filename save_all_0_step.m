%% This code will save all the prepared and normalized data in a way that they can be used for running LSTM and BLSTM network


speaker_amount=[];  %Will save the amount of data for each speaker
All_data=[]; %Save the data portion only after reshaping. Not the labels
LABELS=[]; %Will save the labels only
i=1;
for sp=1:10
    
    load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/0_step/NORMALIZED/step0_normalized_s_%d',sp));
    speaker_amount=[speaker_amount;size(normalized_semi,2)];
    
    for u=1:size(normalized_semi,2)
        
        All_Data(i,:,:)=transpose(normalized_semi(u).data);  %The All_Data is saved the data in 3 dimensions. The first dimension indicates
        %the data/utterance index. The remaining the dimensions are row and
        %columns.
        LABELS=[LABELS;normalized_semi(u).label];
        i=i+1;
        
    end
    disp(sp)
    
    
    
end

csvwrite('Sadat/IEMOCAP_forcasting/sameframe/0_step/CSV/time_data_0_step_forecast.csv',All_Data);
csvwrite('Sadat/IEMOCAP_forcasting/sameframe/0_step/CSV/label_0_step_forecast.csv',LABELS);
r=1;
speaker_id=[];  % It is necessary for letting the program know, which data is of which speaker
for i=1:10
    
    speaker_id(r:r+speaker_amount(i)-1,1)=i;
    r=r+speaker_amount(i);
end
csvwrite('Sadat/IEMOCAP_forcasting/sameframe/0_step/CSV/speaker_group.csv',speaker_id)    
    




save('Sadat/IEMOCAP_forcasting/sameframe/0_step/CSV/0_step_speakerUtterance_amount.mat','speaker_amount')