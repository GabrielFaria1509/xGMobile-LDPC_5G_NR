function r = Gerador_r(y, p)
   
r = zeros([1 length(y)]);

for i = 1:length(y)
    if y(i) == 1
        r(i) = log(p/(1-p));
    else
        r(i) = log((1-p)/p);
    end
end