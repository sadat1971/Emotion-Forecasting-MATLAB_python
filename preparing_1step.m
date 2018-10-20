%This code prepare data for the task of 1-step forecasting
%find the average lengths of values
LENS=[];
MEANS=[];
STDS=[];
NN=[];
st=1; %change it to 2,3 for step 2 and 3
%Let's shift the emotion label by 1 step
for sp=1:10
    gathered_data=[];
    AVd=[];
    All_data=[];
    gathered_data=load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/All_audiovisual/AV_samelength_s_%d.mat',sp));
    j=1;
    for  i=1:(length(gathered_data.AV)-st)
        
        next_name=gathered_data.AV(i+st).name;
        
        a=split(next_name,'_F');
        name1=split(a{1},'_M');
        a=split(gathered_data.AV(i).name,'_F');
        name2=split(a{1},'_M');
        
        All_data(j).name=gathered_data.AV(i).name;
        All_data(j).audio=gathered_data.AV(i).audio;
        All_data(j).video=gathered_data.AV(i).video;
        
        if(strcmp(name1{1},name2{1}))
            All_data(j).label=gathered_data.AV(i+st).label;
        else
            All_data(j).label=10;
        end
        
        
        if All_data(j).label<4
            LENS=[LENS;size(All_data(j).audio,1)];
            AVd=[AVd;All_data(j).audio All_data(j).video];
        end
        
        j=j+1;
    end
    MEANS=[MEANS;mean(AVd,1)];
    STDS=[STDS;std(AVd,1)];
    disp(sp)
    save(sprintf('Sadat/IEMOCAP_forcasting/sameframe/%d_step/emo_shifted/step%d_emoshifted_s_%d.mat',st,st,sp),'All_data');
end

    
    

M=floor(max(LENS));


%Normalize the data
for sp=1:10
    normalized_semi=[];
    DATA=[];
    DATA=load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/%d_step/emo_shifted/step%d_emoshifted_s_%d.mat',st,st,sp));
    k=1;
    for i=1:length(DATA.All_data)
        
        if DATA.All_data(i).label<4
            
            normalized_semi(k).name=DATA.All_data(i).name;
            Full_data=[DATA.All_data(i).audio DATA.All_data(i).video];
            normal=[];
            normal=(Full_data-MEANS(sp,:))./STDS(sp,:);
            normalized_semi(k).data=padarray(normal,M-size(normal,1),0,'post');
            normalized_semi(k).label=DATA.All_data(i).label;
            k=k+1;
        end
        
        
    end
    
    save(sprintf('Sadat/IEMOCAP_forcasting/sameframe/%d_step/NORMALIZED/step%d_normalized_s_%d',st,st,sp),'normalized_semi')
    disp(sp)
end

