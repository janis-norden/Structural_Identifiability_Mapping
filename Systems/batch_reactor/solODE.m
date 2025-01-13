% DESCRIPTION: calculates numerically the solution to the batch reactor system 

% INPUT: 
% t:        time vector
% params:   parameter vector
% OUTPUT:   array sol containing the timeseries of the UI system
function sol = solODE(t, params)
    
    % Unpack leak parameters
    b1 = params(1);
    b2 = params(2);
   mum = params(3);
    Ks = params(4);
     Y = params(5);
    Kd = params(6);
    
    % Define RHS of ODE
    x0 = [b1; b2];
    fun = @(t, x) [(mum * x(2) * x(1)) / (Ks + x(2)) - Kd * x(1);
                  -(mum * x(2) * x(1)) / (Y * (Ks + x(2)))];
    
    % solve using 4th order Runge-Kutta
    [~, sol] = ode45(fun, t, x0);
    sol = sol';

end