% DESCRIPTION: calculates analytically the solution to UI system 

% INPUT: 
% t:        time vector
% params:   parameter vector
% OUTPUT:   array sol containing the timeseries of the UI system
function sol = solODE(t, params)
    
    % unpack parameters
    kPex = params(1);
    kLex = params(2);
    kPL  = params(3);
    kLP  = params(4);
    
    % set initial condition
    S0 = 2000;
    kabs = 21.3443 / S0;
    x0   = [S0; 0; 0];

    % construct A matrix
    A = [ -kabs,             0,             0;
           kabs, -(kPex + kPL),           kLP;
              0,           kPL, -(kLex + kLP)];

    % check if eigenvalues are distinct
    [eigV, eigVals] = eig(A);
    numDisEigs = length(unique(diag(eigVals)));
    % if n distinct eigenvalues -> solve directly, else solve using matrix-exp
    if numDisEigs == size(A, 1) && isreal(diag(eigVals)) % solve directly
        % solve for c-coefficients
        c = eigV \ x0;
        % construct solution as lin. comb. of eigenvectors
        sol = eigV * diag(c) * exp(diag(eigVals) * t);
    else % solve using matrix exponential
        sol = zeros(length(x0), length(t));
        for i = 1:length(t)
            sol(:, i) = expm(t(i) * A) * x0;
        end
    end
end