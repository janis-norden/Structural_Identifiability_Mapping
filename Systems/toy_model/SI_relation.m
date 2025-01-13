% Realizes coordiante transformation inspired by SI relationships
% INPUT: original parameters
% OUTPUT: SI transformed parameters
function PhiPars = SI_relation(pars)
    PhiPars = pars(:, 1) .* pars(:, 2);
end