%% This code prepare data for the task of 1-step forecasting
%At the end of the code, we will find a prepared dataset for 1- step
%forecasting. The preparation includes normalization and zero padding at
%the end 

%Input:  
%  st: step number (1, 2 or 3)

% Created By: 
%           Sadat Shahriar
%           last modified: 10-27-2018


function UF_preparing_cur(st)

mkdir temp_data
LENS=[]; %It will save the lengths of features. The longest utterance will have the biggest value
MEANS=[];  %for saving the means for normalizartion
STDS=[]; %for saving the stds for normalization
NN=[];
%Let's shift the emotion label by 1 step
sprintf('data is being forecasting-shifted')

for sp=1:10
    gathered_data=[];
    FC=[];
    AVd=[];
    All_data=[]; %will save the n-step shifted data and labels
    gathered_data=load(sprintf('data_reformed/sp_%d_stat.mat',sp));
    j=1;
    for  i=1:(length(gathered_data.stat)-st) %remember, the last utterance will not have any labels.
        
        
        %First, let's compare the current utterance and to-be-forecasted
        %utterance. If they are of same speaker and same dialog, record
        %that. Otherwise, ignore.
        next_name=gathered_data.stat(i+st).name;
        
        a=split(next_name,'_F');
        name1=split(a{1},'_M');
        a=split(gathered_data.stat(i).name,'_F');
        name2=split(a{1},'_M');
        
        All_data(j).name=gathered_data.stat(i).name;
        All_data(j).data=gathered_data.stat(i).data;
        All_data(j).for_FC=gathered_data.stat(i).for_FC;
        if(strcmp(name1{1},name2{1}))
            All_data(j).label=gathered_data.stat(i+st).labels;
        else
            All_data(j).label=10; % There is no label named '10'. We are using that just to keep track of the utterances that need to be removed.
        end
        
        
        if All_data(j).label<4  %we will take 0-3 labels only
            LENS=[LENS;size(All_data(j).data,1)];
            AVd=[AVd;All_data(j).data];
            FC=[FC;All_data(j).for_FC];
        end
        
        j=j+1;
    end
    MEANS=[MEANS;mean(AVd,1)];
    NN=[NN;zscore(FC)]; %Here it is normalized for FC
    STDS=[STDS;std(AVd,1)];
    sprintf('data is being prepared for %d step forecasting for upto speaker %d',st,sp)
    save(sprintf('temp_data/step%d_emoshifted_s_%d.mat',st,sp),'All_data');
end

save('temp_data/FC_forecast.mat','NN')



M=max(LENS);

sprintf('data is being Normalized for UF-cur')

%% Normalize the data
for sp=1:10
    normalized_semi=[]; %That will contain the normalized data
    DATA=[];
    DATA=load(sprintf('temp_data/step%d_emoshifted_s_%d.mat',st,sp));
    k=1;
    for i=1:length(DATA.All_data)
        
        if DATA.All_data(i).label<4
            
            normalized_semi(k).name=DATA.All_data(i).name;
            Full_data=[DATA.All_data(i).data];
            normal=[];
            normal=(Full_data-MEANS(sp,:))./STDS(sp,:);
            normalized_semi(k).data=padarray(normal,M-size(normal,1),0,'post'); %this is zero-padding at the end. If the
            %utternace is smaller than the longer utterance, pad 0 at the end and make
            %it of same size
            normalized_semi(k).label=DATA.All_data(i).label;
            k=k+1;
        end
        
        
    end
    
    save(sprintf('temp_data/step%d_normalized_s_%d.mat',st,sp),'normalized_semi')
    sprintf('data is being normalized for %d step forecasting for upto speaker %d',st,sp)

end
end
