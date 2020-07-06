function new_audios = RMSNormalization(audios)
    % reference: https://www.hackaudio.com/digital-signal-processing/amplitude/rms-normalization/
    % http://replaygain.hydrogenaud.io/proposal/rms_energy.html
    for i = 1:size(audios,2)
        oldLevel = sqrt(mean(audios(i).^2));
        maxValue = max(abs(audios(i)));
        newLevel = 0.99 * oldLevel / maxValue;
        
        levels(i) = newLevel;
    end
    
    minPa = min(levels);
    minRMS = 20 * log10(minPa+10^-10);
end