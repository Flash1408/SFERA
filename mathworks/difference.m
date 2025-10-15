clc
clearvars

modelName = 'Ebike'; 

%Load model
load_system(modelName);
faults = Simulink.fault.findFaults(modelName);
fm = Simulink.fault.getFaultModels(modelName);
load_system(fm(1));

allBlocks = find_system(fm(1), 'FollowLinks', 'on', 'LookUnderMasks', 'all');
for b = 11:length(allBlocks)
    parts = regexp(allBlocks(b),'/','split'); 
    if strcmp(parts{1,1}{1,2}, faults(3).Name)
        try
            blkType = get_param(allBlocks(b), 'Name');
        catch
            blkType = 'Unknown';
        end

        try
            params = get_param(allBlocks(b), 'DialogParameters');
        catch
            params = {};
        end
    end
end


set_param('Ebike_FaultModel/Zero_OrderHold_Outport1_fault/White Noise', 'Mean', '2')
componentList = unique({faults.ModelElement});
selected = 'Ebike/Step/Outport/1';
filterfaults = faults(strcmp({faults.ModelElement}, selected));
f = faults(1);
nf = length(filterfaults);

startTime = 10;
endTime = 20;

for i = 2:nf
    if faults(i).IsActive
            % --- tuning fault ---

            % --- Simulation with fault off ---
            Simulink.fault.enable(faults(i).ModelElement,false);
            simIn1  = Simulink.SimulationInput(modelName);
            simIn1 = simIn1.setModelParameter('StopTime', num2str(endTime));
            simOut1 = sim(simIn1);

            if faults(i).TriggerType == "Conditional"
                if faults(i).Conditional.LogActivity == false
                    faults(i).Conditional.LogActivity = true;
                end
            end
            % --- Simulation with fault ON ---
            Simulink.fault.enable(faults(i).ModelElement,true);
            simIn2  = Simulink.SimulationInput(modelName);
            simIn2 = simIn2.setModelParameter('StopTime', num2str(endTime));
            simOut2 = sim(simIn2);


            % --- Estraction logged signals ---
            t  = simOut1.logsout{1}.Values.Time;
            y1 = simOut1.logsout{1}.Values.Data;
            y2 = simOut2.logsout{1}.Values.Data;

            % --- Difference ---
            yDiff = y1 - y2;


        % --- Time window ---
         % --- Get Conditional signal to find start time ---
         runID = Simulink.sdi.getCurrentSimulationRun(modelName);
         signals = runID.getAllSignals;
         for j = 1: length(signals)
             if strcmp('Conditionals', signals(j).Domain)
                 cond_signal = signals(j);
             end
         end

        idxFirst = find(cond_signal.Values.Data == 1, 1, 'first');
        idxLast  = find(cond_signal.Values.Data == 1, 1, 'last');
        
        % Ottieni i tempi corrispondenti
        tFirst = cond_signal.Values.Time(idxFirst);
        tLast   = cond_signal.Values.Time(idxLast);
    
        % Trova gli indici in 't' più vicini a questi tempi
        idxStart = find(t >= tFirst, 1, 'first');
        idxEnd = find(t <= tLast, 1, 'last');
        yWin = yDiff(idxStart:idxEnd);
        tWin = t(idxStart:idxEnd);


        % --- Cleaning signal ---
        % [y, idx] = cleanSignal(yWin, 'adaptive');

        % --- Compute changing points ---
        changePts = swSegmentation(yWin, tWin);


        % --- create segments ---
        segments = cell(length(changePts)-1,1);
        for k = 1:length(segments)
            segments{k} = yWin(changePts(k):changePts(k+1)-1);
        end


        % === 3. Analysis ===
        N = length(segments);
        result = cell(N, 2);
        
        for k = 1:N
            seg = segments{k};
            [isDiv, howDiv] = isDivergent(seg);
            result{k,1} = isDiv;
            result{k,2} = howDiv;
        end
    end
end
        
       


