% DESCRIPTION: calculates analytically the solution to the simple
% unidentifiable toy model

% INPUT: 
% t:        time vector
% pars:     parameter vector
% OUTPUT:   array sol containing the timeseries of the toy model
function sol = solODE(t, pars)
    a = pars(1);
    b = pars(2);
    sol = exp(-(a * b) .* t);
end