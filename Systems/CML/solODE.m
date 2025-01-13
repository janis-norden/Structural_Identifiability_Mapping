% DESCRIPTION: calculates analytically the solution to CML system 

% INPUT: 
% t:        time vector
% params:   parameter vector
% OUTPUT:   array sol containing the timeseries of the UI system
function sol = solODE(t, params)
    
    % number of compartments
    n = 4;

    % set initial condition
    S0 = 2000;
    kabs = 21.3443 / S0;
    x0 = zeros(n + 1, 1);
    x0(1)= S0;
    
    % Unpack leak parameters
    k01 = params(1);
    k02 = params(2);
    k03 = params(3);
    k04 = params(4);
    
    % unpack conversion parameters
    k12 = params(5);
    k23 = params(6);
    k34 = params(7);
    k21 = params(8);
    k42 = params(9);
    k43 = params(10);

    % Define matrix A and initial condition
    A_inner = [ -(k01 + k21),                k12,                    0,               0;
                   k21, -(k02 + k12 + k42),                  k23,               0;
                     0,                  0,   -(k03 + k23 + k43),             k34;
                     0,                k42,                  k43,   -(k04 + k34)];
    

    % add input as additional compartment
    A = zeros(size(A_inner) + 1);
    A(2:end, 2:end) = A_inner;
    A(1, 1) = -kabs;
    A(2, 1) = kabs;

    % solve using 4th order Runge-Kutta
    [~, sol] = ode45(@(t, x) A*x, t, x0);
    sol = sol';

    % % check if eigenvalues are distinct
    % [eigV, eigVals] = eig(A);
    % numDisEigs = length(unique(diag(eigVals)));
    % % if n distinct eigenvalues -> solve directly, else solve using matrix-exp
    % if numDisEigs == n && isreal(diag(eigVals)) % solve directly
    %     % solve for c-coefficients
    %     c = eigV \ x0;
    %     % construct solution as lin. comb. of eigenvectors
    %     sol = eigV * diag(c) * exp(diag(eigVals) * t);
    % else % solve using matrix exponential
    %     sol = zeros(length(x0), length(t));
    %     for i = 1:length(t)
    %         sol(:, i) = expm(t(i) * A) * x0;
    %     end
    % end
end