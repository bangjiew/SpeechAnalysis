function fftplot(audio1, audio2, Fs, speaker1, speaker2, txt)
   
    cond = 2; % default condition
    if nargin < 1 error('no arguments'); end
    if nargin < 6 txt = ' '; end
    if nargin < 5 speaker2 = ' '; end
    if nargin < 4 speaker1 = ' '; end
    if nargin < 3 
        Fs = 8000; % default sample size      
    end
    if nargin < 2 cond = 1; end
    
    if cond == 1
        % Plot power spectrum
        L = size(audio1,2);           
        Y = fft(audio1);
        P2 = abs(Y/L);
        P1 = P2(1:ceil(L/2)+1);
        f = Fs*(0:ceil(L/2))/L;
        figure;
        plot(f,P1);
    elseif cond == 2
        % FFT
        L = max([size(audio1,2) size(audio2,2)]);        
        Y1 = fft(audio1,L);
        Y2 = fft(audio2,L);
        P2_1 = abs(Y1/L);
        P1_1 = P2_1(1:ceil(L/2)+1);
        P2_2 = abs(Y2/L);
        P1_2 = P2_2(1:ceil(L/2)+1);
        P = P1_1 - P1_2; % power difference
        f = 16000*(0:ceil(L/2))/L; % frequency

        % Plot power difference spectrum
        figure;
        plot(f,smooth(P));
        title(['Power Difference between ', speaker1, ' and ', speaker2, ' -- ',txt]);
        xlabel('Frequency');
        ylabel('Power');       
    end
end