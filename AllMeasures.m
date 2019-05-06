%% STEP 1: Read file
clear all

INPUT_PATH = '~\SampleData\sample_sounds\'; % change INPUT_PATH
data = dir(INPUT_PATH);
file_type = '.wav'; % change file type if needed
count = 1;
for i = 1:size(data,1)
    name = data(i).name;
    if contains(name, file_type) 
        audios{count} = name;
        count = count + 1;
    end
end
%% STEP 2: Feature extraction
for k = 1:size(audios,2)
    audio= strcat(INPUT_PATH, audios{k});
    [y, fs] = audioread(audio);
    info = audioinfo(audio);
    
    audioIn = y(:,1);
    dur_tot(k) = info.Duration;

    % Amplitude
    amp_rms(k) = rms(audioIn);
    % Not sure if abs is needed
    amp_min(k) = min(abs(audioIn)); % wouldn't it be always 0????
    amp_max(k) = max(abs(max(audioIn)));
    amp_std(k) = std(abs(audioIn));

    % Intensity
    ydb = abs(db(audioIn));
    for i = 1:size(audioIn,2) 
        count = 1;
        curr = 0;
        for j = 1:size(audioIn,1)
            temp = ydb(j,i);
            if (temp ~= -Inf) && (temp ~= Inf) && ~isnan(temp) 
                curr = curr + temp;
                count = count + 1;
            end
            int_mean_temp(i) = curr/count;
        end
    end
    int_mean(k) = int_mean_temp;
    % Pitch
    [f0,idx] = pitch(audioIn,fs);
    ptc_mean(k) = mean(f0);
    ptc_min(k) = min(f0);
    ptc_max(k) = max(f0);
    ptc_std(k) = std(f0);

    % Spectrum
    % y = fft(audioIn)
    % count = 0;
    % for i = 1:size(result,1) 
    %     if real(result(i)) > 0
    %         selected(i) = result(i);
    %         count = count+1;
    %     end
    % end
end

%% STEP3: Write features into file

%Change the output path
path = '~\SampleData\AllMeasures.xls';
title = {'name', 'dur_tot', 'amp_min', 'amp_max', 'amp_std', 'int_mean', 'ptc_mean', 'ptc_min', 'ptc_max', 'ptc_std'};

xlswrite(path,title,'1','A1');
xlswrite(path, audios','1','A2');
xlswrite(path, features, '1', 'B2');
disp('DONE');