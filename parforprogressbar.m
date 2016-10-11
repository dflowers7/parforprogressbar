classdef parforprogressbar < handle
    % PARFORPROGRESSBAR is a progress bar for parfor loops.
    %
    % *How to use: 
    % Initialize the progress bar immediately before the
    % parfor loop by calling
    %
    % pb = parforprogressbar(nIterations)
    %
    % where nIterations is the number of iterations for the loop.
    % Somewhere in the loop, preferably toward the end, add the line
    %
    % pb.printbar(ii)
    %
    % where ii is the index of the current iteration. ii should range from
    % 1 to nIterations.
    %
    % *Example:
    % nSamples = 1000;
    % pb = parforprogressbar(nSamples);
    % parfor samplei = 1:nSamples
    %    ...Your code here...
    %    pb.printbar(samplei)
    % end
    %
    % Copyright David Flowers, 2016. All rights reserved.
    % Licensed under the MIT License
    
    properties
        ntasks
        nbars = 50;
        shouldIprint
    end
    
    methods
        
        function obj = parforprogressbar(ntasks)

            %gcp; % Initialize pool if necessary. Only necessary to ensure
            %text from starting parallel pool doesn't offset the progress
            %bar.
            
            obj.ntasks = ntasks;
            
            % Handle zero task case
            if ntasks == 0
                obj.shouldIprint = [];
            
            else
                
                nbarspertask = obj.nbars/ntasks;

                % shouldIprintabar is a vector indicating how many bars should be printed
                % on the completion of each task
                if nbarspertask < 1e-2
                    obj.shouldIprint = sparse(ntasks,1);
                else
                    obj.shouldIprint = zeros(ntasks,1);
                end

                % If more bars than tasks, each job should print at least one bar. Set up
                % each task to print this minimum number of bars.
                if nbarspertask > 1
                    obj.shouldIprint(:) = nbarspertask - rem(nbarspertask,1);
                    nbarspertask = rem(nbarspertask,1);
                end

                % There may be a remainder number of bars. Add these remaining bars to
                % random tasks.
                indices = 1:ntasks;
                for ii = 1:(nbarspertask*ntasks)
                    chooseoneremainingindex = ceil(rand*length(indices));
                    obj.shouldIprint(indices(chooseoneremainingindex)) = obj.shouldIprint(indices(chooseoneremainingindex)) + 1;
                    indices(chooseoneremainingindex) = [];
                end
            
            end
            
            % Print the bar length indicator. End with a space, since a backspace comes first.
            fprintf([repmat('.',1,obj.nbars) '\n '])
            
        end
        
        function printbar(obj,ii)

            if obj.shouldIprint(ii) > 0
                % Backspace to get rid of newlines from disp ...
                fprintf('\b')
                % ... and print a bar. Print multiple, if necessary. Use disp so
                % that the command window is updated more often.
                disp(repmat('|',1,obj.shouldIprint(ii)))
            end
        end
        
    end
    
end
