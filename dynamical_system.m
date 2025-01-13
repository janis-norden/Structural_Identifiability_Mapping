classdef dynamical_system
    % DESCRIPTION: dynamical_system class
    %   The purpose of this class is to help organize example systems and
    %   their respective properties and methods.
    
    % PROPERTIES
    properties
        name            % string with name of the system
        ROI             % matrix defining region of interest
        numStateVars    % number of state variables in the model
        obsIdx          % vector indicating which variables are observed
        solODE          % function handle to solution of ODE system
        SI_relation     % function handle to SI relation
    end
    
    % METHODS
    methods

        function self = dynamical_system(name, ID)
            
            % DESCRIPTION: Loads information stored in
            % 'Systems/selected_system/systemInfo.mat' and initializes an
            % instance of the dynamical_system class with the loaded
            % information.

            % INPUT:
            % name:   string indicating the name of the system to load
            % ID:     string indicating whether to load the ID or UID
            %         version of the system
            
            % loads system info from folder
            rmpath(genpath('Systems'))
            addpath(genpath(['Systems/', name]))

            % load system information from saved file
            load(['Systems/', name, '/systemInfo.mat'], 'numStateVars', 'obsIdx', 'ROI')

            % assign properties
            self.name = name;
            self.numStateVars = numStateVars;
            if isequal(ID, 'UID')
                self.obsIdx = obsIdx;
            else
                self.obsIdx = 1:numStateVars;
            end
            self.ROI = ROI;
            self.solODE = @(t, par) solODE(t, par);
            self.SI_relation = @(par) SI_relation(par);
        end

        function timeseries = genTSGrid(self, params, tGrid, sigmaObs)
            % DESCRIPTION: generates noisy timeseries data points on
            % timegrid

            % INPUT:
            % params:           parameter vector
            % t:                vector of times at which the analyt. solution is computed
            % sigma:            stand. dev. of sampling noise for observed x
            
            % OUTPUT:           
            % timeseries:       matrix containing timeseries

            % Evaluate solution at the selected sample times
            sol = self.solODE(tGrid, params);

            % Extract observed components
            solObs = sol(self.obsIdx, :);

            % Create noise vectors (isotropic noise)
            obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(tGrid));

            % Add noise to solution and store in TS
            timeseries = [tGrid; solObs + obsNoise];
        end

        function timeseries = genTSAppointment(self, params, tGrid, sigmaObs, appointPars)
            % DESCRIPTION: generates irregular and sparse timeseries data
            % according to "doctors appointment" scheme

            % INPUT:
            % params:           parameter vector
            % t:                vector of times at which the analyt. solution is computed
            % appointPars:      struct containing appointment parameter gap and
            %                   window
            % pDropout:         probability that patient does not make an
            %                   appointment
            % sigma:            stand. dev. of sampling noise for observed x
            
            % OUTPUT:           
            % timeseries:       matrix containing timeseries
            
            % extract apointment gap and window from input
            gap = appointPars.gap;
            window = appointPars.window;
            pDropout = appointPars.pDropout;
            
            % make sure tAppoint has at least 3 elements
            tAppoint = 0;
            while length(tAppoint) < 3
                % set first appointment time and set droput counter to 0
                tAppoint = unifrnd(tGrid(1), tGrid(1) + gap);
                cntDropout = 0;

                % iterate over appointments and simulate droputs
                while tAppoint(end) < tGrid(end) && tAppoint(end) + (cntDropout + 1) * gap - window < tGrid(end)
                    if rand < pDropout
                        cntDropout = cntDropout + 1;
                    else
                        tAppoint = [tAppoint, unifrnd(tAppoint(end) + (cntDropout + 1) * gap - window, tAppoint(end) + (cntDropout + 1) * gap + window)];
                        cntDropout = 0;
                    end
                end

                % if last appointment is after last allowed time, trim tAppoint
                if tAppoint(end) > tGrid(end)
                    tAppoint = tAppoint(1:end - 1);
                end
            end

            % use genTSGrid to generate timeseries on appointment grid
            timeseries = self.genTSGrid(params, tAppoint, sigmaObs);

        end

        function Lhood = LikelihoodFun(self, timeseries, pars, sigmaObs)
            % DESCRIPTION: Calculates the likelihood of observing the timeseries data
            % given a parameter value k with fixed standard deviation sigma
            
            % INPUT: 
            % timeseries:   matrix containing the timeseries
            % pars:         vector containing the model parameters
            % sigmaObs:     number giving the std. of Gaussian
            %               observational noise on the data

            % OUTPUT:
            % Lhood:    number giving the likelihood of the timeseries
            %           given the parameters and assuming the noise is
            %           Gauss-distributed N(0, sigmaObs)

            % extract time points and observations
            t = timeseries(1, :);
            xObs = timeseries(2:end, :);

            % calc. trajectory with current parameter setting, reduce to obs. components
            muPar = self.solODE(t, pars);
            muParObs = muPar(self.obsIdx, :);

            % calculate likelihood
            Sigma = (sigmaObs .^2) * eye(size(xObs, 1));
            Lhood = prod(mvnpdf(xObs', muParObs', Sigma));
        end
        
        function LLhood = LogLikelihoodFun(self, timeseries, pars, sigmaObs)
            % DESCRIPTION: Calculates the log-likelihood of observing the timeseries data
            % given a parameter value k with fixed standard deviation sigma
            
            % INPUT: 
            % timeseries:   matrix containing the timeseries
            % pars:         vector containing the model parameters
            % sigmaObs:     number giving the std. of Gaussian
            %               observational noise on the data

            % OUTPUT:
            % LLhood:    number giving the log-likelihood of the timeseries
            %            given the parameters and assuming the noise is
            %            Gauss-distributed N(0, sigmaObs)

            % extract time points and observations
            t = timeseries(1, :);
            xObs = timeseries(2:end, :);

            % calc. trajectory with current parameter setting, reduce to obs. components
            muPar = self.solODE(t, pars);
            muParObs = muPar(self.obsIdx, :);

            % calculate likelihood
            Sigma = (sigmaObs .^2) * eye(size(xObs, 1));
            LLhood = sum(log(mvnpdf(xObs', muParObs', Sigma)));
        end
        
        function tsData = genBinLabelTSGrid(self, numTrainExamples, parClass, t, sigmaObs)
            % DESCRIPTION:  Generates data and labels for a binary
            % classification task on a regular time grid

            % INPUT:
            % numTrainExamples:     number giving the total amount of timeseries
            % parClass:             struct containing information defining the generative models for each class
            % parClass.C0.mu:       vector containing the mean C0.mu for class 0
            % parClass.C0.Sigma:    matrix containing the cov. mat. for class 0
            % parClass.C1.mu:       vector containing the mean C0.mu for class 1
            % parClass.C1.Sigma:    matrix containing the cov. mat. for class 1
            % t:                    vector of times at which the analyt. solution is computed
            % sigmaObs:             number giving the std. of Gaussian observational noise on the data

            % OUTPUT:         
            % tsData:               struct containing timeseries (field 1) and labels (field 2)
            
            % extract relevant variables
            C0 = parClass.C0;
            C1 = parClass.C1;

            % initialize data struct
            observations = struct('truePar', {}, 'timeseries', {}, 'label', {});
            
            % generate timeseries from class C0
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C0.mu, C0.Sigma);
                sol = self.solODE(t, par);
                    
                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(t));

                % Add noise to solution and store in TS
                timeseries = [t; solObs + obsNoise];

                % store in observations struct
                observations(count + 1).truePar = par';
                observations(count + 1).timeseries = timeseries;
                observations(count + 1).label = 0;

                % update counter
                count = count + 1;
                
            end

            % generate timeseries from class C1
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C1.mu, C1.Sigma);
                sol = self.solODE(t, par);

                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(t));

                % Add noise to solution and store in TS
                timeseries = [t; solObs + obsNoise];

                % store in observations struct
                observations(numTrainExamples + count + 1).truePar = par';
                observations(numTrainExamples + count + 1).timeseries = timeseries;
                observations(numTrainExamples + count + 1).label = 1;

                % update counter
                count = count + 1;

            end

            tsData.observations = observations;
            tsData.sigmaObs = sigmaObs;

        end

        function tsData = genBinLabelTSAppoint(self, numTrainExamples, parClass, t, sigmaObs, appointPars)
            % DESCRIPTION:  Generates data and labels for a binary
            % classification task on an irregular appointment-style time grid

            % INPUT:
            % numTrainExamples:     number giving the total amount of timeseries
            % parClass:             struct containing information defining the generative models for each class
            % parClass.C0.mu:       vector containing the mean C0.mu for class 0
            % parClass.C0.Sigma:    matrix containing the cov. mat. for class 0
            % parClass.C1.mu:       vector containing the mean C0.mu for class 1
            % parClass.C1.Sigma:    matrix containing the cov. mat. for class 1
            % t:                    vector of times at which the analyt. solution is computed
            % sigmaObs:             number giving the std. of Gaussian observational noise on the data
            % appointPars:          struct containing appointment parameters gap and
            %                       window      

            % OUTPUT:         
            % tsData:               struct containing timeseries (field 1) and labels (field 2)
            
            % extract relevant variables
            C0 = parClass.C0;
            C1 = parClass.C1;

            % initialize data struct
            observations = struct('truePar', {}, 'timeseries', {}, 'label', {});
            
            % generate timeseries from class C0
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C0.mu, C0.Sigma);
                timeseries = self.genTSAppointment(par, t, sigmaObs, appointPars);

                % store in observations struct
                observations(count + 1).truePar = par';
                observations(count + 1).timeseries = timeseries;
                observations(count + 1).label = 0;

                % update counter
                count = count + 1;
                
            end

            % generate timeseries from class C1
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C1.mu, C1.Sigma);
                timeseries = self.genTSAppointment(par, t, sigmaObs, appointPars);

                % store in observations struct
                observations(numTrainExamples + count + 1).truePar = par';
                observations(numTrainExamples + count + 1).timeseries = timeseries;
                observations(numTrainExamples + count + 1).label = 1;

                % update counter
                count = count + 1;

            end

            tsData.observations = observations;
            tsData.sigmaObs = sigmaObs;




            % % extract relevant variables
            % C0 = parClass.C0;
            % C1 = parClass.C1;
            % 
            % % Initialize data struct
            % observations = struct('truePar', {}, 'timeseries', {}, 'label', {});
            % 
            % for it = 1:numTrainExamples
            % 
            %     % Generate a random label
            %     label = round(rand);
            % 
            %     % Sample timeseries according to label
            %     if label == 0
            %         % draw parameter from C0 distribution
            %         par = mvnrnd(C0.mu, C0.Sigma);
            %         TS = self.genTSAppointment(par, t, sigmaObs, appointPars);
            %     else
            %         % draw parameter from C0 distribution
            %         par = mvnrnd(C1.mu, C1.Sigma);
            %         TS = self.genTSAppointment(par, t, sigmaObs, appointPars);
            %     end
            % 
            %     % Store timeseries and associated label in data struct
            %     observations(it).truePar = par';
            %     observations(it).timeseries = TS;
            %     observations(it).label = label;
            % 
            % end
            % tsData.observations = observations;
            % tsData.sigmaObs = sigmaObs;

        end
        
        function tsData = genBinLabelTSIrr(self, numTrainExamples, parClass, t, sigmaObs, sparseGridFact)
            % DESCRIPTION:  Generates data and labels for a binary
            % classification task on an irregular time grid

            % INPUT:
            % numTrainExamples:     number giving the total amount of timeseries
            % parClass:             struct containing information defining the generative models for each class
            % parClass.C0.mu:       vector containing the mean C0.mu for class 0
            % parClass.C0.Sigma:    matrix containing the cov. mat. for class 0
            % parClass.C1.mu:       vector containing the mean C0.mu for class 1
            % parClass.C1.Sigma:    matrix containing the cov. mat. for class 1
            % t:                    vector of times at which the analyt. solution is computed
            % sigmaObs:             number giving the std. of Gaussian observational noise on the data
            % sparseGridFact:       number givining the factor for grid sparsity

            % OUTPUT:         
            % tsData:               struct containing timeseries (field 1) and labels (field 2)
            
            % extract relevant variables
            C0 = parClass.C0;
            C1 = parClass.C1;

            % initialize data struct
            observations = struct('truePar', {}, 'timeseries', {}, 'label', {});

            % divide time grid into 1 / sparseGridFact intervals and
            % determine endpoints of these intervals
            numIntervals = round(length(t) * sparseGridFact);
            endPointsVec = linspace(t(1), t(end), numIntervals);
            
            % generate timeseries from class C0
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution, random time points and solve ODE
                par = mvnrnd(C0.mu, C0.Sigma);
                tRand = [t(1), unifrnd(endPointsVec(1:end - 1), endPointsVec(2:end))];
                sol = self.solODE(tRand, par);
                    
                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(tRand));

                % Add noise to solution and store in TS
                timeseries = [tRand; solObs + obsNoise];

                % store in observations struct
                observations(count + 1).truePar = par';
                observations(count + 1).timeseries = timeseries;
                observations(count + 1).label = 0;

                % update counter
                count = count + 1;
                
            end

            % generate timeseries from class C1
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C1.mu, C1.Sigma);
                tRand = [t(1), unifrnd(endPointsVec(1:end - 1), endPointsVec(2:end))];
                sol = self.solODE(tRand, par);

                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(tRand));

                % Add noise to solution and store in TS
                timeseries = [tRand; solObs + obsNoise];

                % store in observations struct
                observations(numTrainExamples + count + 1).truePar = par';
                observations(numTrainExamples + count + 1).timeseries = timeseries;
                observations(numTrainExamples + count + 1).label = 1;

                % update counter
                count = count + 1;

            end

            tsData.observations = observations;
            tsData.sigmaObs = sigmaObs;

        end

        function tsData = genBinLabelTSIrrRand(self, numTrainExamples, parClass, t, sigmaObs, sparseGridFact)
            
            % DESCRIPTION:  Generates data and labels for a binary
            % classification task on an irregular time grid where time
            % points are chosen uniformly at random

            % INPUT:
            % numTrainExamples:     number giving the total amount of timeseries
            % parClass:             struct containing information defining the generative models for each class
            % parClass.C0.mu:       vector containing the mean C0.mu for class 0
            % parClass.C0.Sigma:    matrix containing the cov. mat. for class 0
            % parClass.C1.mu:       vector containing the mean C0.mu for class 1
            % parClass.C1.Sigma:    matrix containing the cov. mat. for class 1
            % t:                    vector of times at which the analyt. solution is computed
            % sigmaObs:             number giving the std. of Gaussian observational noise on the data
            % sparseGridFact:       number givining the factor for grid sparsity

            % OUTPUT:         
            % tsData:               struct containing timeseries (field 1) and labels (field 2)

            % extract relevant variables
            C0 = parClass.C0;
            C1 = parClass.C1;

            % initialize data struct
            observations = struct('truePar', {}, 'timeseries', {}, 'label', {});
            
            % generate timeseries from class C0
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution, random time points and solve ODE
                par = mvnrnd(C0.mu, C0.Sigma);
                tDraw = unifrnd(t(1), t(end), 1, ceil(sparseGridFact * length(t)) - 1);
                tRand = [t(1), sort(tDraw)];
                sol = self.solODE(tRand, par);
                    
                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(tRand));

                % Add noise to solution and store in TS
                timeseries = [tRand; solObs + obsNoise];

                % store in observations struct
                observations(count + 1).truePar = par';
                observations(count + 1).timeseries = timeseries;
                observations(count + 1).label = 0;

                % update counter
                count = count + 1;
                
            end

            % generate timeseries from class C1
            count = 0;
            while count < numTrainExamples

                % draw parameter from class distribution and solve ODE
                par = mvnrnd(C1.mu, C1.Sigma);
                tDraw = unifrnd(t(1), t(end), 1, ceil(sparseGridFact * length(t)) - 1);
                tRand = [t(1), sort(tDraw)];
                sol = self.solODE(tRand, par);

                % Extract observed components
                solObs = sol(self.obsIdx, :);

                % Create noise vector (isotropic noise)
                obsNoise = normrnd(0, sigmaObs, size(solObs, 1), length(tRand));

                % Add noise to solution and store in TS
                timeseries = [tRand; solObs + obsNoise];

                % store in observations struct
                observations(numTrainExamples + count + 1).truePar = par';
                observations(numTrainExamples + count + 1).timeseries = timeseries;
                observations(numTrainExamples + count + 1).label = 1;

                % update counter
                count = count + 1;

            end

            tsData.observations = observations;
            tsData.sigmaObs = sigmaObs;

        end

        function mleData = tsData2mleData(self, tsData)

            % DESCRIPTION:  Find Maximum Likelihood Estimate (MLE) for each timeseries observation in tsData and appends to tsData.

            % INPUT:
            % tsData:   struct containing the timeseries data for the binary classification task

            % OUTPUT:               
            % mleData:  struct copy of tsData with added Maximum Likelihood Estimates (MLE)

            % Unpack sigma and number of observations from input data
            sigmaObs = tsData.sigmaObs;
            numObs = size(tsData.observations, 2);

            % set threshold for Chi-Squ. CDF
            alpha = 0.999;
            xThreshold = chi2inv(alpha, 1);
            
            % initialize structure to hold observations
            observations = struct('truePar', {}, 'timeseries', {}, 'MLE_theta', {}, 'MLE_Phi', {}, 'label', {}, 'optExitFlag', {});

            % set bounds and options for simulated annealing
            lb = self.ROI(:, 1);
            ub = self.ROI(:, 2);
            options = optimoptions(@simulannealbnd, 'Display', 'off', 'TimeLimit', 60);
            
            % unpack to avoid having to communicate to all workers
            LogLikelihoodFunHandle = @(timeseries, pars, sigmaObs) self.LogLikelihoodFun(timeseries, pars, sigmaObs);
            tsDataObs = tsData.observations;
            calcMSEHandle = @(param, timeseries) self.calcMSE(param, timeseries);
            SI_relationHandle = @(param) self.SI_relation(param);
            
            % Parallel for loop over number of observations
            parfor obs = 1:numObs
                
                % set negative log-likelihood function and draw x0 from ROI
                fun = @(pars) -(LogLikelihoodFunHandle(tsDataObs(obs).timeseries, pars, sigmaObs));
                
                % loop to exclude outliers from MLE using MSE test
                selected = false;
                while selected == false

                    % find suitable initial point (100 trials)
                    x0_select = unifrnd(lb, ub);
                    for cnt = 1:100
                        x0 = unifrnd(lb, ub);
                        llogCurrent = fun(x0_select)
                        llogNew = fun(x0);
                        if ~isinf(llogNew) && llogNew < llogCurrent
                            x0_select = x0;
                        end
                    end
                    
                    % solve constrained minimization problem
                    [MLECand, ~, exitflag, ~] = simulannealbnd(fun, x0_select, lb, ub, options);
    
                    % calculate MSE between MLE solution and input timeseries
                    MSE = calcMSEHandle(MLECand, tsDataObs(obs).timeseries);
                    
                    % check if observation is within alpha% range, otherwise discard
                    if MSE / (sigmaObs^2) <= xThreshold
                        selected = true;
                    end
                end

                % store MLE and label in observations struct
                observations(obs).truePar = tsDataObs(obs).truePar;
                observations(obs).timeseries = tsDataObs(obs).timeseries;
                observations(obs).MLE_theta = MLECand;
                observations(obs).MLE_Phi = SI_relationHandle(MLECand')';
                observations(obs).label = tsDataObs(obs).label;
                observations(obs).optExitFlag = exitflag;
                
            end
            mleData.observations = observations;
            mleData.sigmaObs = sigmaObs;

        end
        
        function MSE = calcMSE(self, params, timeseries)
            % DESCRIPTION:  Extracts time points given in timeseries and
            % constructs solution according to parameter setting param at
            % these time points, calculates Mean Squared Error (MSE) between the observations

            % INPUT:
            % params:        parameter vector
            % timeseries:   matrix containing the timeseries

            % OUTPUT:               
            % MSE:          number giving the Mean Squared Error
       
            % extract time points
            t = timeseries(1, :);

            % construct hypothesis solution
            hypoSol = self.genTSGrid(params, t, 0);

            % calculate MSE
            MSE = (1/length(t)) * sum(vecnorm(hypoSol(2:end, :) - timeseries(2:end, :)).^2);

        end
    end
end