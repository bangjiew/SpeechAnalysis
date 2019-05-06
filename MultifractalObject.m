classdef MultifractalObject
    % MULTIFRACTALOBJECT 
    %--------------references-----------------   
    % https://doi.org/10.1080/10407413.2013.753804 
    % https://doi.org/10.3389/fphys.2018.01152
    
    properties
        audio % Must be a X by 1 double matrix, where X is a positive integer
        sum_audio % Sum of the values of all data points in audio
    end

    methods
        function obj = MultifractalObject(audio)
            % Constructor for MultifractalObject
            obj.audio = audio;
            obj.sum_audio = sum(audio);
        end
        
        function value = MFDFA(obj, q_left, q_right, Lj_left, Lj_right)
            disp('*************STARTED*************');
            count = 1;
            for q = q_left:q_right
                % Initialize
                alpha_temp = 0;
                f_temp = 0;

                for L_j = Lj_left:Lj_right
                    % Split test_data into N_j samples 
                    N_j = 2^L_j;
                    bin_len = length(obj.audio) / N_j;
                    
                    % In case that bin_len is not an integer
                    if ~(isinteger(bin_len)) 
                        bin_upper = ceil(bin_len);
                        bin_lower = floor(bin_len);
                    else 
                        bin_upper = bin_len;
                        bin_lower = bin_len;
                    end 
                    
                    for i = 1:N_j
                        if isinteger(i/2)
                            % When i/2 is not an integer
                            samples{i} = obj.audio((i-1)*bin_lower+1:i*bin_upper);
                        else 
                            % When i/2 is an integer
                            samples{i} = obj.audio((i-1)*bin_upper+1:i*bin_lower);
                        end 
                    end
                    
                    % Calculate the sum of P_ij in a specific q at a given
                    % Scale L_j
                    sum_total = 0;
                    for k = 1:length(samples) 
                        sum_total = sum_total + obj.proportion(samples{k})^q;
                    end
                    
                    for j = 1:N_j 
                        alpha_temp(j) = alpha(obj, q, samples, j, sum_total);
                        f_temp(j) = hausdorff(obj, q, samples, j, sum_total);
                    end
                    
                    alpha_sample(L_j-Lj_left+1) = sum(alpha_temp);
                    f_sample(L_j-Lj_left+1) = sum(f_temp);
                end
                
                alpha_set{count} = alpha_sample;
                f_set{count} = f_sample;
                
                disp('q = '+q);
                count = count + 1;
            end
            
            value{1} = alpha_set;
            value{2} = f_set;
            
            disp('*************TERMINATED*************');
        end
        
        function prop = proportion(obj, bin)
            %Estimates bin-level proportion P_i(L) within bin i of scale L
           
            %Arguments: obj, a MultifractalObject
            %           bin, a double 1D array
            %Return: prop, a double number
            %Note: the equation 1 in Ward and Kelty-Stephen (2018)
            %assumes that the data are divided evenly. In our case this
            %will not always happen, so we use sum instead.
            
            prop = sum(bin)/obj.sum_audio;
        end
        
        function m = mass(obj, q, samples, i, sum_total)
            %Calculates the mass of the proportion P_i(L) within bin i of
            %   scale L
            
            %Arguments: obj, a MultifractalObject
            %           q, an integer
            %           samples, a double 1D array
            %           i, a positive integer
            %Return: m, a double
            
            sum_bin = proportion(obj,samples{i})^q;
            
            m = sum_bin / sum_total;
        end

         function a = alpha(obj, q, samples,i, sum_total)
            %Calculates the alpha value (slope) of the given q 
            %   i.e. mass weighted log(proportion)
            
            %Arguments: obj, a MultifractalObject
            %           q, an integer
            %           samples, a double 1D array
            %Return: a, a double
            
            avg_prop = mass(obj, q, samples, i, sum_total)*log(proportion(obj, samples{i}));
           
            % Take the avg just in case the sample sizes are different
            if length(samples) == 1
                avg_len = length(samples{1});
            else
                avg_len = (length(samples{1}) + length(samples{2})) / 2;
            end
            
            a = avg_prop / log(avg_len);
         end
        
        function f = hausdorff(obj, q, samples, i, sum_total)
            %Calculates the Hausdorff dimension f(q)
            %   i.e. mass weighted log(mass)
            
            %Arguments: obj, a MultifractalObject
            %           q, an integer
            %           samples, a double 1D array
            %Return: f, a double

            temp_mass = mass(obj, q, samples, i, sum_total);
            avg_mass = temp_mass*log(temp_mass);
            
            % Take the avg just in case the sample sizes are different
            if length(samples) == 1
                avg_len = length(samples{1});
            else
                avg_len = (length(samples{1}) + length(samples{2})) / 2;
            end
            
            f= avg_mass / log(avg_len);
        end
    end
end

