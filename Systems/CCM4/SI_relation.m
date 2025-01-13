% INPUT: original parameters
% OUTPUT: SI transformed parameters
function PhiPars = SI_relation(pars)

    % set dimension of CCM system
    n = 4;
    
    % arrange parameter in sub and super diagonal matrix fashion
    SDPars = pars(:, n+1:2*n-1);
    LDPars = pars(:, 2*n:3*n-2);
    excPars = pars(:, 1:n);
    
    % construct identifiabble combinations
    Phi1 = -excPars(:, 1) -  LDPars(:, 1);
    Phii = -excPars(:, 2:n-1) - SDPars(:, 1:n-2) - LDPars(:, 2:n-1);
    Phin = -excPars(:, n) -  SDPars(:, n-1);
    PhiPars1 = [Phi1, Phii, Phin];
    
    PhiPars2 = LDPars .* SDPars;
    
    % combine into output matrix
    PhiPars = [PhiPars1, PhiPars2];
    
end