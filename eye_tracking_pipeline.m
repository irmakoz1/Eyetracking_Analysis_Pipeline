%% example displaying gaze, heatmap, pupil size and triggers


%
% The analysis script can be used to separate an edf file into the trials by defining
% one of the analysis messages.
%
% REQUIREMENTS: Edf2Mat toolbox

clear;clc;close all;
% Add Edf2mat toolbox
addpath('E:\0024_CBT_UNIGE_VUILLEUMIER\Curiosity\eye_tracking\edf-converter-master');


%% import data

subpath     = 'E:\0024_CBT_UNIGE_VUILLEUMIER\Curiosity\subject_data\CURIOSITY008NG';
edf{1, 1}   = Edf2Mat(fullfile(subpath,'008NG_1.edf'));
subject     = 1;
run         = 1;
load(fullfile(subpath,'CuriosityTask_1'))

%% reorder edf for following processes
edfData     = edf.'; 
edfData     = edfData(:);
runs        = repmat(1:numel(run), 1, numel(subject));
subjects    = repmat(1:numel(subject), numel(run), 1);



%% find the fixation center of the data
% predefine veriables
fullGazeData = cell(numel(edf), 1);
screenWidth  = cell(numel(edf), 1);
screenHeight = cell(numel(edf), 1);
center       = cell(numel(edf), 1);

currSamp = 1;
%% loop variables
currSubj   = subject(subjects(currSamp));
currRun    = run(runs(currSamp));
currData   = edfData{currSamp};

%% find the screen coordination data
infoName = 'GAZE_COORDS';
screenSize = cellfun(@(x) strncmp(x, infoName, numel(infoName)), currData.Events.Messages.info(:));
screenSize = strsplit(currData.Events.Messages.info{screenSize}, " ");
screenSize = str2double(screenSize(end-3:end));

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




%% split data for each trial
% triggerName = 'stimuli presentation';
triggerName = {'stimulus','outcome'};

% get timestamps of the trigger
triggerTimestamps    = {};
triggerRange        = {};

%%% stimuli match with normalized time%%%


event = {edf_eye.RawEdf.FEVENT.message}';
time_events = cell2mat({edf_eye.RawEdf.FEVENT.sttime}');
time_events1 = cell2mat({edf_eye.RawEdf.FEVENT.sttime});
time_ALLnorm=edf_eye.normalizedTimeline;
time_ALL=edf_eye.timeline;
edf_eye.RawEdf.FEVENT.message%the stimulus is here
edf_eye.normalizedTimeline%timestartfrom 0

%%%

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

 
%%%%time%%

for nt = 1:length(triggerName)

    ts = find(contains(currData.Events.Messages.info(:),triggerName{nt}))
    tmp = currData.Events.Messages.time(ts);

    triggerRange{nt}(1,:) = tmp;
    triggerRange{nt}(2,:) = tmp+2.5*500;

end


% stimulus tringger
triggerRange = struct();
tmp_stim = currData.Events.Messages.time(find(contains(currData.Events.Messages.info(:),triggerName{1})));

triggerRange.stim(1,:) = tmp_stim;
triggerRange.stim(2,:) = tmp_stim+2.5*500;


tmp_out = repmat(NaN,90,1); % initialize 

for o = 1:90
    
    str = sprintf('outcome %d onset', o);
    
    count = find(ismember(currData.Events.Messages.info,str));

    if ~isempty(count)
        tmp_out(o) = currData.Events.Messages.time(count);
    end
end


triggerRange.out(1,:) = tmp_out;
triggerRange.out(2,:) = tmp_out+2.5*500;


% Inputs
door                    = find(CuriosityTask.Trial==1); % Door choice only
inst_ignored            = find(CuriosityTask.Trial==2 & ~isnan(CuriosityTask.Response) & CuriosityTask.Response<3); % instrumental curiosity trial
inst_chosen             = find(CuriosityTask.Trial==2 & ~isnan(CuriosityTask.Response) & CuriosityTask.Response==3); % instrumental curiosity trial
noninst_ignored         = find(CuriosityTask.Trial==3 & ~isnan(CuriosityTask.Response) & CuriosityTask.Response<4); % instrumental curiosity trial
noninst_chosen          = find(CuriosityTask.Trial==3 & ~isnan(CuriosityTask.Response) & CuriosityTask.Response==4); % instrumental curiosity trial

% Outcomes
reward                  = find(CuriosityTask.Reward==1); % Door choice only 
noreward                = find(CuriosityTask.Reward==2); % Door choice only 
instOut                 = find(CuriosityTask.InstrumentalCuriosity==1); % Door choice only 
noninstOut              = find(CuriosityTask.NoninstrumentalCuriosity==1); % Door choice only 

triggerDataRange        = struct();

% stimuli timing
triggerDataRange.door                       = triggerRange.stim(:,door);
triggerDataRange.inst_ignored               = triggerRange.stim(:,inst_ignored);
triggerDataRange.inst_chosen                = triggerRange.stim(:,inst_chosen);
triggerDataRange.noninst_ignored            = triggerRange.stim(:,noninst_ignored);
triggerDataRange.noninst_chosen             = triggerRange.stim(:,noninst_chosen);

% outcomes timing
triggerDataRange.reward                     = triggerRange.out(:,reward);
triggerDataRange.noreward                   = triggerRange.out(:,noreward);
triggerDataRange.instOut                    = triggerRange.out(:,instOut);
triggerDataRange.noninstOut                 = triggerRange.out(:,noninstOut);






start    = triggerDataRange.reward(1,1)
endd     = triggerDataRange.reward(1,2)

%gazedata pos,pupils etc. for timestamps
currData.Samples.posY(find(currData.Samples.posY==start:endd))

cond = fields(triggerDataRange)





%% run for each trial (range from 'stimuli presentation'
allIndices = 1:numel(currData.Samples.time);

for cc = 1:length(cond)
    x = [];
    x = triggerDataRange.([cond{cc}]);

    for currentRange = 1:size(x,2)


        % Due to it's not sure if the exact timestamp of the trigger is available in the recordings, the indices are
        % selected as range
        rangeIndices = allIndices(currData.Samples.time >= x(1, currentRange) ...
            & currData.Samples.time < x(2, currentRange));

        triggerInRangeBool = currData.Events.Messages.time >= x(1, currentRange) ...
            & currData.Events.Messages.time < x(2, currentRange);

        % Due to trigger timestamp does not match with frequency, adjust it
        triggerTimeing = round((currData.Events.Messages.time(triggerInRangeBool) - x(1, currentRange))./(1000/frequency)).';
        trigger = table(triggerTimeing, string(currData.Events.Messages.info(triggerInRangeBool)).', 'VariableNames', {'time', 'info'});

        % figure(currSamp * 100 + currRun * 10 + currentRange); clf;
        %% plot gaze data
%                 subplot(2, 2, 1);
        
                posX(:,currentRange) = currData.Samples.posX(rangeIndices);
                % Y must be inverted, because eyetracker origin
                % is upper left corner in a graph its the lower left
                posY(:,currentRange) = currData.Samples.posY(rangeIndices) * -1;
                plot(posX, posY, 'o', 'Color','blue');
        


    end
                plot(nanmean(posX,2), nanmean(posY,2), 'o', 'Color','blue');

    title('Plot of the eye movement');
            axis([min(posX) - 1 max(posX) + 1 min(posY) - 1 max(posY) + 1]);
            axis('square');
            xlabel('x-Position');
            ylabel('y-Position');


        %% plot heatmap
%         subplot(2, 2, 2);
%         [ht(:,:,currentRange), ~, axisRange] = currData.heatmap(min(rangeIndices), max(rangeIndices));
% 
%         imhandle = imagesc(mean(ht,3));
% 
%         set(imhandle.Parent, 'YDir','normal');
%         axis(axisRange);
%         axis square;
%         colorbar;
%         title('HeatMap of the eye movement');
%         xlabel('x-Position (shifted zero)');
%         ylabel('y-Position (shifted zero)');


        %% plot pupil diameter
%         subplot(2, 2, 3);
%         plot(currData.Samples.pupilSize(rangeIndices), 'Color', 'blue')
%         hold on
%         lineXpos = repmat(trigger.time, 1, 2);
%         y = ylim;
%         lineYpos = repmat([y(1), y(2)], height(trigger), 1);
%         line(lineXpos.', lineYpos.', 'Color', 'red')
%         hold off
%         title('Pupil Size and triggers');
%         xlabel('data point (ca. ms)');
%         if logical(currData.PUPIL.AREA)
%             ylabel('Area (SR Research points)');
%         else
%             ylabel('Diameter (SR Research points)')
%         end


    %% add trigger names to last subplot
    subplot(2, 2, 4);
    test = rowfun(@(x, y) string(sprintf('%d: %s\n', x, y)), trigger, 'OutputVariableNames', 'description');
    text(0,0.5, join(test.description)); axis off

end



