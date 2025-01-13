% DESCRIPTION: calculates analytically the solution to UI system 

% INPUT: 
% t:        time vector
% params:   parameter vector
% OUTPUT:   array sol containing the timeseries of the UI system
function sol = solODE(t, params)
    
    % set size of CCM model
    n = 4;

    % set initial condition
    S0 = 2000;
    kabs = 21.3443 / S0;
    x0 = zeros(n + 1, 1);
    x0(1)= S0;
    
    % find A: desconstruct into superdiag. subdiag. and diagonal parts
    SD = diag(params(n+1:2*n-1), 1);
    LD = diag(params(2*n:3*n-2), -1);
    D1 = diag(params(1:n));
    dVec = -sum(LD + D1 + SD, 1);
    D = diag(dVec);
    A_inner = D + SD + LD;
    
    % add input as additional compartment
    A = zeros(size(A_inner) + 1);
    A(2:end, 2:end) = A_inner;
    A(1, 1) = -kabs;
    A(2, 1) = kabs; 

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