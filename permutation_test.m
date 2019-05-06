function stats = permutation_test(audio1, audio2, num_runs, sample_size)
% Permutation test for the powers of each frequency of audio1 and audio2
% Arguments: audio1, a double array
%            audio2, a double array
%            num_runs, a positive integer (range: 1000-10000)
%            sample_size, a positive integer
% Returns: stats, a struct with fields surrogate data, p_values, upper
%            and lower bounds.
cond = 2;
if nargin < 1 error('no arguments'); end
if nargin < 4 sample_size = 125000; end
if nargin < 3 num_runs = 1000; end
if nargin < 2 cond = 1; end

if cond == 1
    % permutations ref:
    audio_size = size(audio1,2);
    
    for i = 1:num_runs
        curr_indices = randperm(audio_size);
        %curr_audioIn_all = Shuffle(audioIn_all);
        
        % reassignment
        for j = 1:audio_size
            sample(j) = audio1(curr_indices(j));
            %sample_one(j) = curr_audioIn_all(j);
        end
        
        %FFT & t-test
        L = size(sample,2);
        Y1 = fft(sample,L);
        P2_1 = abs(Y1/L);
        P1_1 = P2_1(1:ceil(L/2)+1);
        
        surrogate(:,i) = P1_1(1:sample_size);
        clear sample L Y1 P2_1 P1_1;
        disp(['num_runs = ', num2str(i)]);
    end
    each_freq = sort(surrogate,2);
    stats.surrogate = surrogate;
    clear surrogate;
    disp('Surrogate data saved.');
    
    % get the largest and the smallest value for each column
    for i = 1:size(each_freq,1)
        upper(i) = each_freq(i,num_runs);
        lower(i) = each_freq(i,1);
        each_freq(i,:) = 0;
    end
    
    stats.upper = upper;
    stats.lower = lower;
    
    disp('Upper and lower saved');
    disp('********** DONE ***********');
    disp(stats);
    
elseif cond == 2
    % permutations ref:
    audioIn_all = [audio1, audio2];
    size_one = size(audio1,2);
    size_two = size(audio2,2);
    total_size = size_one + size_two;
    
    for i = 1:num_runs
        curr_indices = randperm(total_size);
        %curr_audioIn_all = Shuffle(audioIn_all);
        
        % reassignment
        for j = 1:size_one
            sample(j) = audioIn_all(curr_indices(j));
            %sample_one(j) = curr_audioIn_all(j);
        end
        
        for k = size_one+1:total_size
            sample_two(k-size_one) = audioIn_all(curr_indices(k));
            %sample_two(k-size_one) = curr_audioIn_all(k);
        end
        
        %FFT & t-test
        L = max([size(sample,2) size(sample_two,2)]);
        Y1 = fft(sample,L);
        Y2 = fft(sample_two,L);
        P2_1 = abs(Y1/L);
        P1_1 = P2_1(1:ceil(L/2)+1);
        P2_2 = abs(Y2/L);
        P1_2 = P2_2(1:ceil(L/2)+1);
        p_value(i) = ttest(P1_1, P1_2);
        
        surrogate{i,1} = P1_1(1:sample_size);
        surrogate{i,2} = P1_2(1:sample_size);
        clear sample_one sample_two L Y1 Y2 P2_1 P1_1 P2_2 P1_2;
        disp(['num_runs = ', num2str(i)]);
    end
    
    stats.p_values = p_value;
    clear p_value;
    disp('p_value saved.');
    
    % difference of surrogate P1_1 and P1_2
    for i = 1:size(surrogate,1)
        each_freq(:,i) = surrogate{i,1} - surrogate{i,2};
    end
    
    each_freq = sort(each_freq,2);
    stats.surrogate = surrogate;
    clear surrogate;
    disp('Surrogate data saved.');
    
    % get the largest and the smallest value for each column
    for i = 1:size(each_freq,1)
        upper(i) = each_freq(i,num_runs);
        lower(i) = each_freq(i,1);
        each_freq(i,:) = 0;
    end
    
    stats.upper = upper;
    stats.lower = lower;
    
    disp('Upper and lower saved');
    disp('********** DONE ***********');
    disp(stats);
end
end


    %         for i = 1:length(surrogate)
    %             diff{i} = surrogate{i,1} - surrogate{i,2};
    %         end
    %
    %         stats.surrogate = surrogate;
    %         clear surrogate;
    %         disp('Surrogate data saved.');
    %
    %         % sort in ascending order
    %         for i = 1:length(diff)
    %             for j = 1:length(diff{1})
    %                 each_freq(i,j) = diff{i}(j);
    %             end
    %         end
    %         sorted_each_freq = sort(each_freq)';
    %        clear diff each_freq;
