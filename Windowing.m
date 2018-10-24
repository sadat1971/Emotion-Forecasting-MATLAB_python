
%% find the statistical values
% this code converts the framewise data to windowwise data.
% At the end of the code, we will convert all our data to windowise
% features. All categorical labels are there (0-9).
% stat(N).name: name of the utterance
% stat(N).data: 895 dimensional statistical featyures
for sp=1:10
    DATA=load(sprintf('Sadat/IEMOCAP_forcasting/sameframe/All_audiovisual/AV_samelength_s_%d.mat',sp)); %the files contain the 179 dimensuinbal framewise data
    stat=[]; %this struct will contain all the windowwise data
    
    for i=1:length(DATA.AV)
        Full_data=[DATA.AV(i).audio DATA.AV(i).video];
        
        %make the matrix range
        a=size(Full_data,1);
        k=1;
        ba=[]; %the desired matrix range. It will have the data like that:  [1 30;16 45;31 60;...].If there remains something less
        % less than 30 at the end, it will calculate the statistical
        % features for that. 
        
        
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
        
        stat(i).name=DATA.AV(i).name;
        stat(i).data=row;
        stat(i).labels=DATA.AV(i).label; %the real time categorical labels
    end
    save(sprintf('Sadat/IEMOCAP_forcasting/sameframe/STATISTICAL/data_reformed/sp_%d_stat.mat',sp),'stat');
    disp(sp)
end
