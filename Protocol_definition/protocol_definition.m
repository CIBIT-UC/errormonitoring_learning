%% 
% ================= PROTOCOL DEFINITION =================

%%
clear all; close all; clc;
%% 
errors_total=0;
correct_total=0;
err_nr = [];
corr_nr = [];

mean_rt = load('F:\SEM_mri_rawdata\mean_rt.mat');
mean_rt = mean_rt.mean_rt_table;
%% 
for s = 1:21 
    
    err_part = 0;
    corr_part = 0;
    
    if s < 10
        sub = strcat('P0',num2str(s));
    else
        sub = strcat('P',num2str(s));
    end
    
    dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\'); % Path
    
    if sub == "A09" || sub == "A15"
        runs = [1:5];
    else
        runs = [1:7];
    end
    
    for r = runs
        
        protocol = {};
        
        nrun = strcat('R',num2str(r));
        responses = load(strcat(dir_files, 'protocol\results_RT_', nrun, '.mat'));  
        responses = responses.responses;
        triggers = load(strcat(dir_files, 'mat_files\', sub, '_', nrun, '.mat'));
        
        start_time = triggers.Output.Run.run_initTime;
        run_time = triggers.Output.Run.runFinalTime - start_time;
        baseline_times = triggers.Output.Run.NoiseTime - start_time;
        triggers = triggers.Output.Run.dataMat;
        triggers(5:10,:) = triggers(5:10,:) - start_time;
        
        mean_rt_sac = cell2mat(mean_rt.Mean_rt_sac(string(mean_rt.Participant)==sub...
            & string(mean_rt.Run)==nrun));
        mean_rt_kp = cell2mat(mean_rt.Mean_rt_kp(string(mean_rt.Participant)==sub...
            & string(mean_rt.Run)==nrun));
        
        ev=1;
        for i=1:height(responses)
            
            protocol{ev,1} = "Instruction";
            protocol{ev,2} = round(triggers(6,i),1);
            protocol{ev,3} = round(triggers(6,i),1);
            protocol{ev,4} = round(triggers(7,i) - triggers(6,i),1);
            protocol{ev,5} = triggers(1,i);
            ev = ev+1;
            
            if (i<48 && string(responses.Result(i+1)) ~= "Late response to previous trial") || i==48
                if string(responses.Result(i)) == "Correct"
                    protocol{ev,1} = "Correct";
                    protocol{ev,2} = round(triggers(8,i));
                    protocol{ev,3} = responses.Reaction_time(i);
                    protocol{ev,4} = 0;
                    protocol{ev,5} = triggers(1,i);
                    correct_total=correct_total+1;
                    corr_part = corr_part +1;
                    ev = ev+1;
                elseif string(responses.Result(i)) == "Error" || ...
                        string(responses.Result(i)) == "Error (anticipated indecision)" || ...
                        string(responses.Result(i)) == "Error (anticipated)" || ...
                        string(responses.Result(i)) == "Action error (correct)" || ...
                        string(responses.Result(i)) == "Anticipated error (both actions contradictory)" || ...
                        string(responses.Result(i)) == "Error (indecision)" || ...
                        string(responses.Result(i)) == "Action error (anticipated correct)" || ...
                        string(responses.Result(i)) == "Action error (anticipated error)" || ...
                        string(responses.Result(i)) == "Action error (anticipated indecision)" || ...
                        string(responses.Result(i)) == "Action error (error)" || ...
                        string(responses.Result(i)) == "Action error (indecision error)" || ...
                        string(responses.Result(i)) == "Both actions (+ET anticipated indecision)"  || ...
                        string(responses.Result(i)) == "Both actions (+KP anticipated error)"  || ...
                        string(responses.Result(i)) == "Both actions (correct +KP anticipated)"  || ...
                        string(responses.Result(i)) == "Both actions (correct +KP)"  || ...
                        string(responses.Result(i)) == "Both actions (correct anticipated +KP)"  || ...
                        string(responses.Result(i)) == "Both actions (error +KP)" || ...
                        string(responses.Result(i)) == "Error (both actions contradictory)" || ...
                        string(responses.Result(i)) == "Both actions (late error +KP anticipated error)" || ...
                        string(responses.Result(i)) == "Both actions (correct +ET)" || ...
                        string(responses.Result(i)) == "Both actions (correct +ET anticipated)" || ...
                        string(responses.Result(i)) == "Both actions (correct anticipated +ET)" 
                    errors_total=errors_total+1;
                    err_part = err_part +1;
                    protocol{ev,1} = "Error"; 
                    protocol{ev,2} = round(triggers(8,i));
                    protocol{ev,3} = responses.Reaction_time(i);
                    protocol{ev,4} = 0;
                    protocol{ev,5} = triggers(1,i);
                    ev = ev+1;
                elseif string(responses.Result(i)) == "Error (no-go)"
                    errors_total=errors_total+1;
                    err_part = err_part +1;
                    protocol{ev,1} = "Error"; 
                    protocol{ev,2} = round(triggers(8,i));
                    if string(responses.Saccade2make(i)) ~= "Fixation" 
                        if mean_rt_sac >= -0.5
                            protocol{ev,3} = round((triggers(8,i)+mean_rt_sac),1);
                        else
                            protocol{ev,3} = round((triggers(8,i)-0.5),1);
                        end
                    else
                        if mean_rt_kp >= -0.5
                            protocol{ev,3} = round((triggers(8,i)+mean_rt_kp),1);
                        else
                            protocol{ev,3} = round((triggers(8,i)-0.5),1);
                        end
                    end
                    protocol{ev,4} = 0;
                    protocol{ev,5} = triggers(1,i);
                    ev = ev+1;
                else 
                    protocol{ev,1} = "Other"; 
                    protocol{ev,2} = round(triggers(8,i));
                    protocol{ev,3} = responses.Reaction_time(i);
                    protocol{ev,4} = 0;
                    protocol{ev,5} = triggers(1,i);
                    ev = ev+1;
                end  
            end
        end
        
        for i=1:length(baseline_times)
            protocol{ev,1} = "Baseline"; 
            protocol{ev,2} = round(baseline_times(i),1);
            protocol{ev,3} = round(baseline_times(i),1);
            if i ~= length(baseline_times)
                protocol{ev,4} = ...
                    round(((triggers(5,find(triggers(5,:)>baseline_times(i),1))) ...
                    - (baseline_times(i))),1);
                protocol{ev,5} = 0;
            else
                protocol{ev,4} = round((run_time - baseline_times(i)),1);
                protocol{ev,5} = 0;
            end
            ev = ev+1;
        end
        
        save(strcat(dir_files,'protocol/protocol_', nrun, '.mat'), 'protocol');
        
    end
    
    err_nr = [err_nr err_part];
    corr_nr = [corr_nr corr_part];
end
