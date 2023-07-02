function mir = getmir(W, data)

    h0 = getent2(data);

    s = W * data; 
    h = getent2(s);
    mir = sum(h0) - sum(h) + sum(log(abs(eig(W))));