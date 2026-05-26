% DESCRIPTION: calculates analytically the solution to UI system 

% INPUT: 
% t:        time vector
% params:   parameter vector
% OUTPUT:   array sol containing the timeseries of the UI system
function sol = solODE(t, params)
    
    % unpack parameters
    S0   = params(1);
    kabs = params(2);
    kPex = params(3);
    kLex = params(4);
    kPL  = params(5);
    kLP  = params(6);
    
    % set initial condition
    x0   = [1e5 * S0; 0; 0];

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