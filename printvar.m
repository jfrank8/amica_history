function printvar(varname,resolution)

if nargin < 2
    resolution = 53;
end

res = sprintf(['%1.' int2str(resolution) 'f,'], varname);
fprintf('%s=[%s];\n', inputname(1), res(1:end-1));
