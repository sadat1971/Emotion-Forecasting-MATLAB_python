%This code will remove all NaN-only data and save the others. Also it will
%downsample the video data as well. 

%% At the end, the data will be saved as a structure
% AV(N).name: name of the utterance
% AV(N).video: 138 video features with all NaN values being removed
% AV(N).audio: all auio fetaures-- pitch, MFCC, MFB and Energy
% AV(N).categorical: All categorical labels

for sp=1:10
    vidata=load(sprintf('Sadat/IEMOCAP_forcasting/Audio_video_all/AV_all_ORIGINAL/All_Audio_visual_s_%d.mat',sp)); %the file contains the original Facuial landmark video data from IEMOCAP
    AV=[]; %This will contain all audio-visual data extracted at a same framerate which is 25 ms framerate
    j=1;
    

% speaker number even is male and odd is female. season 1 contains speaker 1 and 2 and season 2 contains speaker 3 and 4 and so on..
    if mod(sp,2)==0
        season=sp/2;
        gender='M';
    else
        season=(sp+1)/2;
        gender='F';
    end
    
    for i=1:length(vidata.All_data)
        if(vidata.All_data(i).name(6)==gender)  %extracting speakerwise
            ptch=importdata(sprintf('Sadat/IEMOCAP_forcasting/audio_features/s%d/%s.pitch',season,vidata.All_data(i).name),'');
            mfcc=importdata(sprintf('Sadat/IEMOCAP_forcasting/audio_features/s%d/%s.mfcc',season,vidata.All_data(i).name),'');
            mfb=importdata(sprintf('Sadat/IEMOCAP_forcasting/audio_features/s%d/%s.mfb',season,vidata.All_data(i).name),'');
            mfcc_data=str2double(split(mfcc(5:end,1))); %The first 4 contains unnecessary data
            mfb_data=str2double(split(mfb(5:end,1)));
            inten=importdata(sprintf('Sadat/IEMOCAP_forcasting/audio_features/s%d/%s.intensity',season,vidata.All_data(i).name),'');
            L=min([size(ptch.data,1) size(inten.data,1) size(mfcc_data,1) size(mfb_data,1)]);
            
            r=[];
            c=[];
            [r,c]=find(isnan(vidata.All_data(i).video));
            count=[];
            count=histc(c,unique(c)) ;
            count=count/size(vidata.All_data(i).video,1);
            MAX=[];
            MAX=max(count);
            
            if ~isempty(find(ptch.data)) && (isempty(count) || MAX<.3)  %checking the zero pitch and taking the features that has more than 30% of video data
                Vdata=[];
                Vdata=vidata.All_data(i).video;
                down_vid=downsample(Vdata,3);
                filled_vid=fillmissing(down_vid,'linear',1); %interpolation
                AV(j).name=vidata.All_data(i).name;
                AV(j).video=filled_vid(1:L,:);
                AV(j).audio=[ptch.data(1:L,:) inten.data(1:L,:) mfcc_data(1:L,:) mfb_data(1:L,:)];
                AV(j).label=vidata.All_data(i).categorical;
                j=j+1;
            end
                sprintf('sp is %d and i is %d',sp,i)

            
        end
    end
    save(sprintf('Sadat/IEMOCAP_forcasting/sameframe/All_audiovisual/AV_samelength_s_%d.mat',sp),'AV');
    sprintf('sp is %d and i is %d',sp,i)
end
