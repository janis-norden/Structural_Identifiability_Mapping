% INPUT: original parameters
% OUTPUT: SI transformed parameters
function PhiPars = SI_relation(pars)
    PhiPars = [pars(:, 1) + pars(:, 3), pars(:, 2) + pars(:, 4), pars(:, 3) .* pars(:, 4)];
end