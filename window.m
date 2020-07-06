classdef window
    properties
        audio
        window_size
        windowStarts
        windowEnds
    end
    
    methods
        % Constructor
        function obj = window(audio, windowStarts, windowEnds)
            obj.audio = audio;
            obj.window_size = length(audio);
            obj.windowStarts = windowStarts;
            obj.windowEnds = windowEnds;
        end
        
        % Calculate eight formants of this audio
        function formants = calc_formants(obj,fft_size)
            L = fft_size;
            
            % Frequency Scale
            scale = [200 400 600 800 1000 2000 3000 4000]; % in Hertz
            scale = round(scale/fs*L)+1;
            min_f = 50; % minimum frequency in hertz
            min_f = round(min_f/fs*L)+1;
            
            % Calculate the spectrum
            Y = abs(fft(obj.audio,fft_size));
            smooth_Y = 20*log10(Y);
            
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
                        index = locs(loc)+pos-1;
                    end
                catch
                    if smooth_Y(pos) > smooth_Y(scale(i))
                        index = pos;
                    else
                        index = scale(i);
                    end
                end
                formants(i) = f(index);
                pos = scale(i)+1;
            end
        end % End of calc_formants
        
        
    end % End of methods
    
    
end % End of window