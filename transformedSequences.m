function tf = transformedSequences()
load annotatedData
list = 1:116;
downSamCoef = 2;

count = 1;
spon1 = ["txt1","txt4","txt5","txt6","txt7"];

for i = 1:length(list)
    temp = annotations(list(i));
    mic_temp = downsample(temp.mic,6);
    mic_temp = real(20*log10(mic_temp/2^-10)); % convert to dB
    seq_count =1;
    vowel_pos = 1;
    
    if mean(contains(spon1,string(temp.text))) ~= 0
        spont_temp = 1;
    else
        spont_temp = 2;
    end
    
    % Sequence
    for j = 1:size(temp.inhaleEnds,2)+1
        vowel_count = 1;
        if j == 1
            % first breathing period
            if temp.vowelOnsets(j) <= temp.inhaleEnds(j)
                % if the first inhale is after the first vowel
                isRunning = 1;
                while isRunning
                    Speaker{count} = temp.speaker;
                    Text{count} = temp.text;
                    Language{count} = temp.language;
                    ReadSpont{count} = spont_temp;
                    VowelNum{count} = vowel_count;
                    SeqNum{count} = seq_count;
                    Vowels{count} = mic_temp(ceil(temp.vowelOnsets(vowel_pos)*downSamCoef)+1:ceil(temp.vowelOnsets(vowel_pos+1)*downSamCoef)-1);
                    JointSolo{count} = temp.jointSolo;
                    vowel_count = vowel_count + 1;
                    count = count + 1;
                    vowel_pos = vowel_pos + 1;
                    if temp.vowelOnsets(vowel_pos) > temp.inhaleEnds(j)
                        isRunning = 0;
                    end
                end
            else
                continue
            end
        elseif j <= size(temp.inhaleEnds,2)
            isRunning = 1;
            while isRunning
                if vowel_pos == length(temp.vowelOnsets)
                    isRunning = 0;
                elseif vowel_pos < length(temp.vowelOnsets)
                    Speaker{count} = temp.speaker;
                    Text{count} = temp.text;
                    Language{count} = temp.language;
                    ReadSpont{count} = spont_temp;
                    VowelNum{count} = vowel_count;
                    SeqNum{count} = seq_count;
                    JointSolo{count} = temp.jointSolo;
                    Vowels{count} = mic_temp(ceil(temp.vowelOnsets(vowel_pos)*downSamCoef):ceil(temp.vowelOnsets(vowel_pos+1)*downSamCoef)-1);
                    vowel_count = vowel_count + 1;
                    count = count + 1;
                    vowel_pos = vowel_pos + 1;
                end
                if vowel_pos >= length(temp.vowelOnsets) || temp.vowelOnsets(vowel_pos) > temp.inhaleEnds(j)
                    isRunning = 0;
                end
            end
        elseif temp.inhaleEnds(j-1) < temp.vowelOnsets(length(temp.vowelOnsets)-1)
            isRunning = 1;
            while isRunning
                Speaker{count} = temp.speaker;
                Text{count} = temp.text;
                Language{count} = temp.language;
                ReadSpont{count} = spont_temp;
                VowelNum{count} = vowel_count;
                JointSolo{count} = temp.jointSolo;
                SeqNum{count} = seq_count;
                if (vowel_pos) >= length(temp.vowelOnsets)
                    Vowels{count} = mic_temp(ceil(temp.vowelOnsets(vowel_pos)*downSamCoef):end);
                    isRunning = 0;
                else
                    Vowels{count} = mic_temp(ceil(temp.vowelOnsets(vowel_pos)*downSamCoef):ceil(temp.vowelOnsets(vowel_pos+1)*downSamCoef));
                end
                vowel_count = vowel_count + 1;
                count = count + 1;
                vowel_pos = vowel_pos + 1;
            end
        end
        seq_count = seq_count + 1;
    end
    
    clear temp mic_temp
    disp("i = " + i);
end

% naming
for i = 1:length(Vowels)
    if mean(Language{i} == 'language1') == 1
        language(i) = 1;
    else
        language(i) = 2;
    end
    
    if mean(Speaker{i} == 'speaker1') == 1
        speaker(i) = 1;
    elseif mean(Speaker{i} == 'speaker2') == 1
        speaker(i) = 2;
    elseif mean(Speaker{i} == 'speaker3') == 1
        speaker(i) = 3;
    elseif mean(Speaker{i} == 'speaker4') == 1
        speaker(i) = 4;
    elseif mean(Speaker{i} == 'speaker5') == 1
        speaker(i) = 5;
    elseif mean(Speaker{i} == 'speaker6') == 1
        speaker(i) = 6;
    elseif mean(Speaker{i} == 'speaker7') == 1
        speaker(i) = 7;
    elseif mean(Speaker{i} == 'speaker8') == 1
        speaker(i) = 8;
    end
    
    if strcmp("txt1", string(Text{i}))
        text(i) = 1;
    elseif strcmp("txt12", string(Text{i}))
        text(i) = 12;
    elseif strcmp("txt14", string(Text{i}))
        text(i) = 14;
    elseif strcmp("txt15", string(Text{i}))
        text(i) = 15;
    elseif strcmp("txt16", string(Text{i}))
        text(i) = 16;
    elseif strcmp("txt4", string(Text{i}))
        text(i) = 4;
    elseif strcmp("txt5", string(Text{i}))
        text(i) = 5;
    elseif strcmp("txt6", string(Text{i}))
        text(i) = 6;
    elseif strcmp("txt7", string(Text{i}))
        text(i) = 7;
    elseif strcmp("txt8", string(Text{i}))
        text(i) = 8;
    elseif strcmp("txt9", string(Text{i}))
        text(i) = 9;
    end
    
    if strcmp("joint", string(JointSolo{i}))
        jointSolo(i) = 2;
    elseif strcmp("solo", string(JointSolo{i}))
        jointSolo(i) = 1;
    end
    readSpont(i) = ReadSpont{i};
    seqNum(i) = SeqNum{i};
    vowelNum(i) = VowelNum{i};
end

vowels = Vowels';
language = language';
speaker = speaker';
text = text';
readSpont = readSpont';
seqNum = seqNum';
vowelNum = vowelNum';
jointSolo = jointSolo';
clearvars -except vowels language speaker text readSpont seqNum vowelNum jointSolo

tf = table(speaker,language,readSpont,jointSolo,text,seqNum,vowelNum,vowels);
end