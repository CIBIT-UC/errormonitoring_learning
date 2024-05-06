%% 
% ================= EXPORT CONN CONDITION FILE =================

%% 
clear all; close all; clc;
%% 
part = 1;
idx=1;
for s = 1%subs

    if s < 10
        sub = strcat('P0',num2str(s));
    else
        sub = strcat('P',num2str(s));
    end

    dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\'); % Directoria
    
    runs = [1:7];

    for r = runs

        nrun = strcat('R',num2str(r));
        protocol = load(strcat(dir_files, 'protocol\protocol_', nrun, '.mat')); 
        protocol = protocol.protocol;

        for t=1:length(protocol) 

            file{idx,1} = protocol{t,1};
            file{idx,2} = part;
            file{idx,3} = r;
            file{idx,4} = protocol{t,3};
            file{idx,5} = protocol{t,4};

            idx = idx+1;

            %   condition_name, subject_number, session_number, onsets, durations
            %   task, 1, 1, 0 50 100 150, 25 (ex)
        end
    end
    part = part+1;
end
%% Save file
file_table = array2table(file, 'VariableNames', {'condition_name', ...
    'subject_number', 'session_number', 'onsets', 'durations'});
writetable(file_table, 'F:\SEM_mri_rawdata\conditions_conn.txt');
