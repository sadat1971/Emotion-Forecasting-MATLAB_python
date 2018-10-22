% This code will take history for n_step forecasting and calculate
% forecasting

st=1; %this is step. change it accordingly
Lall=[];
for sp=1:10
    load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/audiovisual_data_reformed_windowwise/sp_%d_stat.mat',sp));
    %put all the names together of main data
    history_unnorm=[];
    all_names=[];
    for J=1:length(stat)
        all_names{J,1}=stat(J).name;
    end    
    
    
    load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/%d_step/NORMALIZED/step%d_normalized_s_%d.mat',st,st,sp))
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
    save(sprintf('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/%d_step/History/Unnormalized/history_sp_%d.mat',st,sp),'history_unnorm')
    disp(sp)
end
