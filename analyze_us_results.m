for i = 1:10
    load(['example-cases/us_testing/vectors/raw/raw__0000' num2str(i) '.mat'])
    raw_u(raw_u == 0) = NaN;
    mean_u = nanmean(raw_u, 2);
    figure()
    plot(mean_u*100, 'o')
end


TO DO:

- average images over time (vector field over image sequence?)
- average images