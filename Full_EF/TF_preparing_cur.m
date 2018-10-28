%This function process the data from the subset of UF (which is saved time-distance wise or TF  1, 2 or 3). 
%The processing includes making the statistical features and normalization.
%Input:  
%  st: step number (1, 2 or 3)
%Output: saves the data after normalization and zero padding


% Created By: 
%           Sadat Shahriar
%           last modified: 10-27-2018

function TF_preparing_cur(st)

load(sprintf('TF_data/%d_timestep.mat',st));

for sp=1:10
 all_data=[];
 MEANS=[]; % Contains the means of each speakers. A 10X895 variable
 STDS=[]; % Contains the standard deviation of each speakers. A 10X895 variable
 speakerwise=[]; % The struct will save the processed data from framewise to windowwise (similar to the f_window() function). 
 jj=1;
 LENS=[];

    for i=1:length(timestep)
        

        if timestep(i).speaker==sp
            speakerwise(jj).name=timestep(i).name;

            
            %% Windowwise Make statistical data
            
            %make the matrix range
            a=[];
            Full_data=[];
            Full_data=timestep(i).data;
            a=size(Full_data,1);
            k=1;
            ba=[]; %the desired matrix range
            for m=1:floor(a/15)
                ba(m,1)=k;
                if k+29<a
                    ba(m,2)=k+29;
                else
                    ba(m,2)=a;
                end
                k=k+15;
                if k>a
                    break;
                end
            end
            
            newdata=[];
            row=[];
            for j=1:size(ba,1)
                 newdata=Full_data(ba(j,1):ba(j,2),:);
                 row=[row...
                     ;mean(newdata,1) std(newdata,1) quantile(newdata,.25) quantile(newdata,.75) quantile(newdata,.75)-quantile(newdata,.25)];
            end
            
            
            speakerwise(jj).data=row;
            speakerwise(jj).label=timestep(i).label;
            speakerwise(jj).for_FC=[mean(Full_data) std(Full_data) quantile(Full_data,.25) quantile(Full_data,.75) quantile(Full_data,.75)-quantile(Full_data,.25)];
            jj=jj+1;
        end
        

    end
 save(sprintf('TF_data/unnorm_speakerwise_s_%d.mat',sp),'speakerwise');
disp(sp)
end

%% This block will normalize the data
NN=[];
 MEANS=[];
 STDS=[];
  LENS=[];
for sp=1:10
load(sprintf('TF_data/unnorm_speakerwise_s_%d.mat',sp));
 all_data=[];

 Fc_data=[];
 j=1;

 for i=1:length(speakerwise)
     
     all_data=[all_data;speakerwise(i).data];
     Fc_data=[Fc_data;speakerwise(i).for_FC];
     LENS=[LENS;size(speakerwise(i).data,1)];

     
 end
 NN=[NN;zscore(Fc_data)];
     MEANS=[MEANS;mean(all_data,1)];
    STDS=[STDS;std(all_data,1)];
    
disp(sp)
 
end
save('temp_data/FC_forecast.mat','NN')

M=max(LENS);
for sp=1:10
    load(sprintf('TF_data/unnorm_speakerwise_s_%d.mat',sp));
NORMALIZED=[];
    for N=1:length(speakerwise)
        NORMALIZED(N).name=speakerwise(N).name;
        normalized=[];
        normalized=(speakerwise(N).data-MEANS(sp,:))./STDS(sp,:);
        NORMALIZED(N).data=padarray(normalized,M-size(normalized,1),0,'post');
        NORMALIZED(N).label=speakerwise(N).label;
    end
    
save(sprintf('TF_data/step%d_normalized_s_%d.mat',st,sp),'NORMALIZED')
 disp(sp)
end
end
