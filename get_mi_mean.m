function res = get_mi_mean(data)
res = get_mi(data);
for i = 1:length(res)
    res(i,i) = NaN;
end
res = nanmean(res(:));
