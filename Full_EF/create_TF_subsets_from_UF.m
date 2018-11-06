

%%   The following piece of code will calculate the time distance of utterance step forecasting and organize all of them in a manner that their time distance fall into a definite time-group
% Created By: 
%           Sadat Shahriar
%           last modefied: 10-27-2018


function create_TF_subsets_from_UF()

disp('started running the create_TF_subsets_from_UF function')
TC=importdata('IEMOCAP_data/Turn_Classified.txt'); %contains name of all utterances
% TC.textdata= {'Utt_ID'             }
%     {'Ses01F_impro01_F000'}
%     {'Ses01F_impro01_M000'}
%     {'Ses01F_impro01_F001'}
%     {'Ses01F_impro01_M001'}
%     {'Ses01F_impro01_F002'}


% utt_ID contains utterance id and utt_gender contains utterance gender. We
% are saving all utterance names and it's gender
% Utt_ID: name of the utterances
% utt_gender: gender of the utternace-- 1 for female and -1 for female is saved
for i=2:length(TC.textdata)
    
    utt_ID(i-1,1)=TC.textdata(i,2);
    flipped=flip(utt_ID{i-1,1});
    % check the utterance is male or female
    if flipped(4)=='F'
        utt_gender(i-1)=1;
    elseif flipped(4)=='M'
        utt_gender(i-1)=-1;
    end   
end

nam=1; %counting all utterance
% The 'All' struct will have name of all utterances that has audio-visual information available and the extracted data
for y=1:10
    
    load(sprintf('All_audiovisual/AV_samelength_s_%d.mat',y));
    for z=1:length(AV)
    All_names{nam,1}=AV(z).name;
    ALL(nam).name=AV(z).name;
    ALL(nam).data=[AV(z).audio AV(z).video];
    nam=nam+1;
    end
    
end

times=[]; %it will count the total time for forecasting, i.e., the distance between current utternace and forecasting label utterance. 0.5*current utterannce length+ in-between utteranes' length + 0.5*forecasted utterannce length
%n_step forecast data
t=1;
%% st denotes the utterance steps. We will gather all utterance steps data,
% count the time-distance of forecasting and regroup them
% End of this block, the struct 'timewise' will have all the utterance names, data, labels and delay time for the forecasting labels

for st=1:3;
    n=1;
    step_1=[]; %Although it says step_1, this struct will contain the data from all steps of utterance forecasting
%and save them here.
        step1_gender=[]; %all genders according to the names of utterance
        step1_names=[];
        
        %save the data and labels from the utterance step forecasting
    for sp=1:10

        load(sprintf('temp_data/step%d_normalized_s_%d.mat',st,sp)); %the normalized data from UF forecasting information is loaded.
        for j=1:length(normalized_semi)
            step1_names{n,1}=normalized_semi(j).name;
            flipped=flip(step1_names{n,1});
            step_1(n).label=normalized_semi(j).label;
            step_1(n).speaker=sp;
            if flipped(4)=='F'
                step1_gender(n,1)=1;
            elseif flipped(4)=='M'
                step1_gender(n,1)=-1;
            end            
            n=n+1;            
        end     
    end

    %find the in-between utterances of the current and forecasted
    %utterances 

    for k=1:length(step1_names)
        gend=step1_gender(k);
        all_gend=[];
        all_gend=find(utt_gender==gend);
        step_1(k).name=step1_names{k,1};
        step_1(k).name_range=utt_ID...
            (find(contains(utt_ID,step1_names{k}))+1:(all_gend...
            ((find(all_gend==find(contains(utt_ID,step1_names{k}))))+st)-1));
        
    end
    
    
    emo=importdata('IEMOCAP_data/IEMOCAP_EmoEvaluation.txt');
    emotions=emo(find(contains(emo,'Ses'))); %contains timing information
    
    %Find the utterance length of each utterance
    for p=1:10039
        splitted_row=split(emotions{p});
        b=regexp(splitted_row,'\d+(\.)?(\d+)?','match');
        out=str2double([b{:}]);
        utt_length(p,1)=out(2)-out(1);
    end
    
    
    tot_delay=[]; %contains the total delay information for all utterances used in UF 1, 2 and 3
    for s=1:length(step_1)    
        time1=0; % half of the length of the current utterance
        time2=0; %length of all utterance in-betweeen
        time3=0; % half of the length of the label utterance
        time=0;
        time1=utt_length(find(contains(emotions,step_1(s).name)))/2;
        if ~isempty(step_1(s).name_range)
            for w=1:length(step_1(s).name_range)-1
                time2=time2+utt_length(find(contains(emotions,step_1(s).name_range{w})));
            end
            time3=utt_length(find(contains(emotions,step_1(s).name_range{length(step_1(s).name_range)})))/2;
        end
        time=time1+time2+time3;
        step_1(s).delay=time;
        tot_delay=[tot_delay;time];
        timewise(t).name=step_1(s).name;
        timewise(t).data=ALL(find(contains(All_names,timewise(t).name))).data;
        timewise(t).label=step_1(s).label;
        timewise(t).delay=time;
        timewise(t).speaker=step_1(s).speaker;
        times=[times;time];
        t=t+1;
        if mod(s,20)==0
        disp(s)
        end
    end
end


%% save the data in time-groupwise by making them of within a definite time range
% The 'timestep' struct contains the grouped TF data. It contains the name, data, label, delay time and speaker id. 



mkdir TF_data
gr_mat=[1 5;5 10;10 15];  %This is the group we want. 1 second to 5 second; 5 second to 10 second and so on
for g=1:3
    group=find(times>=gr_mat(g,1) & times<gr_mat(g,2));
    timestep=[]; %this will save the groupwise data
    for L=1:length(group)
        timestep(L).name=timewise(group(L)).name;
        timestep(L).data=timewise(group(L)).data;
        timestep(L).label=timewise(group(L)).label;
        timestep(L).delay=timewise(group(L)).delay;
        timestep(L).speaker=timewise(group(L)).speaker;
       if mod(L,20)==0
       sprintf('L is %d and g is %d',L,g)
       end
    end
    save(sprintf('TF_data/%d_timestep.mat',g),'timestep')

end

end
