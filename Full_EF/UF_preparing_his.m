% This code will take history for utterance forecasting and prepare data for
% forecasting. This function has a dependendency and it is, we must run
% UF_preparing_cur first.

% Created By: 
%           Sadat Shahriar
%           last modified: 10-27-2018
function UF_preparing_his(st)

sprintf('running UF cur first')
UF_preparing_cur(st);
sprintf('UF-cur completes. Now UF-his will be started')

%% first, we will add the history with the current data
for sp=1:10
    load(sprintf('data_reformed/sp_%d_stat.mat',sp));
    %put all the names together of main data
    history_unnorm=[];
    all_names=[];
    for J=1:length(stat)
        all_names{J,1}=stat(J).name;
    end    
    
    
    load(sprintf('temp_data/step%d_normalized_s_%d.mat',st,sp))
    for i=1:length(normalized_semi)
        U_name=normalized_semi(i).name;
        F=find(contains(all_names,U_name));
        if F~=1
            N=stat(F-1).name;
            a=split(N,'_F');
            name1=split(a{1},'_M');
            a=split(stat(F).name,'_F');
            name2=split(a{1},'_M');
            if strcmp(name1{1},name2{1})
                history_unnorm(i).data=[stat(F-1).data;stat(F).data];
                history_unnorm(i).name=normalized_semi(i).name;
                history_unnorm(i).label=normalized_semi(i).label;
                
                
            else
                history_unnorm(i).data=[stat(F).data];
                history_unnorm(i).name=normalized_semi(i).name;
                history_unnorm(i).label=normalized_semi(i).label;

            end
        else
            history_unnorm(i).data=[stat(F).data];
            history_unnorm(i).name=normalized_semi(i).name;
            history_unnorm(i).label=normalized_semi(i).label;
     
        end
        
        
        
    end
    save(sprintf('temp_data/history_sp_%d.mat',sp),'history_unnorm')
    sprintf('data is being processed for %d step forecasting for upto speaker %d',st,sp)
end

%% Now we will prepare the data
% This code will normalize and make the data of same size using zero
% padding at the end

%This code prepare data for the task of n-step forecasting
    %find the average lengths of values
    
    LENS=[];
    MEANS=[];
    STDS=[];
    NN=[];
for sp=1:10
    
    av=[];
    DATA=load(sprintf('temp_data/history_sp_%d.mat',sp));
    

    for i=1:length(DATA.history_unnorm)
        
 
            LENS=[LENS;size(DATA.history_unnorm(i).data,1)];
            av=[av;DATA.history_unnorm(i).data];
        
        
    end
    MEANS=[MEANS;mean(av,1)];
    STDS=[STDS;std(av,1)];
    disp(sp)

end

M=floor(max(LENS));


%Normalize the data
for sp=1:10
    normalized_semi=[];
    DATA=[];
    DATA=load(sprintf('temp_data/history_sp_%d.mat',sp));
    k=1;
    for i=1:length(DATA.history_unnorm)
        
        if DATA.history_unnorm(i).label<4
            
            normalized_semi(k).name=DATA.history_unnorm(i).name;
            Full_data=[DATA.history_unnorm(i).data];
            normal=[];
            normal=(Full_data-MEANS(sp,:))./STDS(sp,:);
            normalized_semi(k).data=padarray(normal,M-size(normal,1),0,'post');
            normalized_semi(k).label=DATA.history_unnorm(i).label;
            k=k+1;
        end
        
        
    end
    
    save(sprintf('temp_data/step%d_normalized_s_%d.mat',st,sp),'normalized_semi')
    sprintf('data is being processed for %d step forecasting for upto speaker %d',st,sp)

end


end
