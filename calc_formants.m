function formants = calc_formants(in,fs,fft_size)

f = (0:fft_size-1)*fs/fft_size;

%h1 = hamming(100)'.^2; % Hamming Curve

% Frequency Scale
scale = [200 400 600 800 1000 2000 3000 4000]; % in Hertz
scale = round(scale/fs*fft_size)+1;
min_f = 50; % minimum frequency in hertz
min_f = round(min_f/fs*fft_size)+1;

% Calculate the spectrum
Y = abs(fft(in,fft_size));
smooth_Y = 20*log10(Y);%filter2(h1,Y));

pos = min_f;
formants = zeros(1,length(scale));

% Find Formants
for i = 1:length(scale)
    try
        [pks,locs] = findpeaks(smooth_Y(pos:scale(i)));
        if isempty(pks)
            index = pos;
        else
            [~,loc] = max(pks);
            index = locs(loc) + pos-1;
        end
        
    catch
        warning('Usage Error using findpeaks: Data set must contain at least three samples.');
        if smooth_Y(pos) > smooth_Y(scale(i))
            index = pos;
        else
            index = scale(i);
        end
    end
    formants(i) = f(index);
    pos = scale(i)+1;
end

end

