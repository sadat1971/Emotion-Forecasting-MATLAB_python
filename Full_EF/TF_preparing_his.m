%This function process the data of TF 1, 2 and 3 and adds previous utterance history. 
%The processing includes making the statistical features and normalization.
%Funcrion Input: st (TF his 1, 2 or 3)
%Output: saves the data after normalization and zero padding
% Created By: 
%           Sadat Shahriar
%           last modified: 10-27-2018

function TF_preparing_his(st)
sprintf('running TF cur first for TF %d',st)
TF_preparing_cur(st);
sprintf('TF-cur completes. Now TF-his will be started')
for sp=1:10
    load(sprintf('data_reformed/sp_%d_stat.mat',sp));
    %put all the names together of main data
    history_unnorm=[];
    all_names=[];
    for J=1:length(stat)
        all_names{J,1}=stat(J).name;
    end    
    
    
    load(sprintf('TF_data/step%d_normalized_s_%d.mat',st,sp))
    for i=1:length(NORMALIZED)
        U_name=NORMALIZED(i).name;
        F=find(contains(all_names,U_name));
        if F~=1
            N=stat(F-1).name;
            a=split(N,'_F');
            name1=split(a{1},'_M');
            a=split(stat(F).name,'_F');
            name2=split(a{1},'_M');
            if strcmp(name1{1},name2{1})
                history_unnorm(i).data=[stat(F-1).data;stat(F).data];
                history_unnorm(i).name=NORMALIZED(i).name;
                history_unnorm(i).label=NORMALIZED(i).label;
               

            else
                history_unnorm(i).data=[stat(F).data];
                history_unnorm(i).name=NORMALIZED(i).name;
                history_unnorm(i).label=NORMALIZED(i).label;
              

            end
        else
            history_unnorm(i).data=[stat(F).data];
            history_unnorm(i).name=NORMALIZED(i).name;
            history_unnorm(i).label=NORMALIZED(i).label;
                        

        end
        
        
        
    end
    save(sprintf('TF_data/history_sp_%d.mat',sp),'history_unnorm')
    sprintf('Now saving the unnnormalized data for TF-his %d upto speaker %d',st,sp)
end

%Normalization
% This code will normalize and make the data of same size using zero
% padding at the end
    LENS=[];
    MEANS=[];
    STDS=[];

for sp=1:10
    
    av=[];
    DATA=load(sprintf('TF_data/history_sp_%d.mat',sp));
    

    for i=1:length(DATA.history_unnorm)
        
 
            LENS=[LENS;size(DATA.history_unnorm(i).data,1)];
            av=[av;DATA.history_unnorm(i).data];
        
        
    end
    MEANS=[MEANS;mean(av,1)];
    STDS=[STDS;std(av,1)];
    disp(sp)

end

M=(max(LENS));


%Normalize the data
for sp=1:10
    normalized_semi=[];
    DATA=[];
    DATA=load(sprintf('TF_data/history_sp_%d.mat',sp));
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
    
    save(sprintf('TF_data/step%d_normalized_s_%d.mat',st,sp),'normalized_semi')
    sprintf('Now saving the normalized and zero padded data for TF-his %d upto speaker %d',st,sp)
end
end
