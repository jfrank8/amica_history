function res = lowest_eig(tmpdata)

    covarianceMatrix = cov(tmpdata', 1);
    [~, D] = eig (covarianceMatrix);
    D = sort(diag(D));
    res = D(1);