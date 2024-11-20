
clear all, clc
addpath('I:\0024_CBT_UNIGE_VUILLEUMIER\Curiosity\eye_tracking\edf-converter-master');


%% import data

subpath     = 'I:\0024_CBT_UNIGE_VUILLEUMIER\Curiosity\subject_data\CURIOSITY008NG';
edf_eye  = Edf2Mat(fullfile(subpath,'008NG_1.edf'));
edfData = edf_eye.'; edfData = edfData(:);

%% find the fixation center of the data
% predefine veriables
fullGazeData = cell(numel(edf_eye), 1);
screenWidth  = cell(numel(edf_eye), 1);
screenHeight = cell(numel(edf_eye), 1);
center       = cell(numel(edf_eye), 1);

for currSamp = 1:numel(edf_eye)
    currData   = edfData(currSamp);

    %% find the screen coordination data
    infoName = 'GAZE_COORDS';
    screenSize = cellfun(@(x) strncmp(x, infoName, numel(infoName)), currData.Events.Messages.info(:));
    screenSize = strsplit(currData.Events.Messages.info{screenSize}, " ");
    screenSize = str2double(screenSize(end-3:end));

      %% split data for each trial
    triggerName = 'stimuli presentation';
    triggerName1 = 'stimulus';
    triggerName2 = 'outcome';


    % get timestamps of the trigger
    %%neeed to divide time to 2 times one for eachh trial , one for each
    %%condition plus two sets income and outcome
    triggerTimestamps = currData.Events.Messages.time(cellfun(@(x) strncmp(x, triggerName, numel(triggerName)), currData.Events.Messages.info(:)));
    
    triggerstimTimestamps = currData.Events.Messages.time(cellfun(@(x) strncmp(x, triggerName1, numel(triggerName1)), currData.Events.Messages.info(:)));
    triggeroutTimestamps = currData.Events.Messages.time(cellfun(@(x) strncmp(x, triggerName2, numel(triggerName2)), currData.Events.Messages.info(:)));
    triggerstimTimestamps=triggerstimTimestamps'
    triggeroutTimestamps=triggeroutTimestamps'
    % create array from one trigger to the next (end for the last trigger is the end of the timeline)
    triggerIdx = arrayfun(@(x) find(x == currData.Samples.time), triggerTimestamps.', 'UniformOutput', false);
    triggerDataRange = [triggerTimestamps; triggerTimestamps(2:end) - 1, max(currData.Samples.time)];


    screenWidth{currSamp}  = screenSize(3) + 1 - screenSize(1);
    screenHeight{currSamp} = screenSize(4) + 1 - screenSize(2);
    currWidth  = screenWidth{currSamp};
    currHeight = screenHeight{currSamp};

    %% find the recording configuration (Hz)
    infoName = 'RECCFG';
    recordingConfig = cellfun(@(x) strncmp(x, infoName, numel(infoName)), currData.Events.Messages.info(:));
    expression = '\d{3,4}'; % RECCFG CR 500 2 1 R --> e.g. expression for 500Hz
    matchStr = regexp(currData.Events.Messages.info{recordingConfig}, expression, 'match');
    frequency = str2double(matchStr{1});
end
%%% stimuli match with time%%%


event = {edf_eye.RawEdf.FEVENT.message}';
time_events = cell2mat({edf_eye.RawEdf.FEVENT.sttime}');
time_events1 = cell2mat({edf_eye.RawEdf.FEVENT.sttime});
time_ALLnorm=edf_eye.normalizedTimeline;
time_ALL=edf_eye.timeline;
edf_eye.RawEdf.FEVENT.message%the stimulus is here
edf_eye.normalizedTimeline%timestartfrom 0

c=0
triggerID1 ={}
triggerID2 ={}
trigger_list1={}
trigger_list={}

    %trigger ID STIMULUS
for i1=1:length(event)  
    if ~isempty(event{i1}) & strfind(event{i1}, 'stimulus')
        c = c +1;
        triggerID1{c} = edf_eye.RawEdf.FEVENT(i1).message;
    end
end

 %trigger ID OUTCOME

e=0

for i2=1:length(event)  
    if ~isempty(event{i2}) & strfind(event{i2}, 'outcome')
        e = e + 1;
        triggerID2{e} = edf_eye.RawEdf.FEVENT(i2).message;
    end
end

%TRIGGER INDEX STIMULI
for i3=1:length(event)  
    if ~isempty(event{i3}) & strfind(event{i3}, 'stimulus')
        trigger_list1{i3}=i3;
    end
end

%TRIGGER INDEX OUTCOME

for i1=1:length(event)  
    if ~isempty(event{i1}) & strfind(event{i1}, 'outcome')
        trigger_list{i1}=i1;
    end
end



trigger_list1=cell2mat(trigger_list1');
trigger_list11=cell2mat(trigger_list1);
trigger_time=time_events{trigger_list11);

trigger_list=cell2mat(trigger_list');
trigger_time2=time_events(trigger_list);

triggerID1=(triggerID1');
%trigger_time=time_events(triggerID1);

triggerID2=(triggerID2');
%trigger_time=time_events(triggerID2);

 % find when time_event happened in ms (normalized time)
 temp=find(ismember(time_ALL,trigger_time));
 trigger_time_ms=time_ALLnorm(temp);

 % create array from one trigger to the next (end for the last trigger is
 % the end of the timeline) FIND THE RANGE AND ADD COLUMN OUTCOME
 % START/END-STIMULUS START/END
    triggerIdx = arrayfun(@(x) find(x == edf_eye.normalizedTimeline), trigger_list1.', 'UniformOutput', false);
    triggerDataRange = [trigger_time; trigger_time(2:end) - 1, max(time_events1)];

    %% next step is to store gaze data as well
    

