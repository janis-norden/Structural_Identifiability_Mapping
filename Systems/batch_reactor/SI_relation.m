% INPUT: original parameters
% OUTPUT: SI transformed parameters
% Equations from "Structural identifiability of the parameters of a
% nonlinear batch reactor model", Chappell and Godfrey (1992)
function PhiPars = SI_relation(params)

    % Unpack parameters
     b1 = params(:, 1);
     b2 = params(:, 2);
    mum = params(:, 3);
     Ks = params(:, 4);
      Y = params(:, 5);
     Kd = params(:, 6);
    
    % set SI-relations
    PhiPars(:, 1) = b1;
    PhiPars(:, 2) = mum;
    PhiPars(:, 3) = Kd;
    PhiPars(:, 4) = b2 .* Y;
    PhiPars(:, 5) = b2 ./ Ks;

end