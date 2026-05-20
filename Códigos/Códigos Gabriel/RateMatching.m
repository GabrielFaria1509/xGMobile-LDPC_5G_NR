function final_code_world = RateMatching(y,Zc)

    %%Standard puncturing definied by 2GPP
    k = length(y); 
    StandardPuncturing = 2*Zc;

    y(1:StandardPuncturing) = [];

    %%Filler bits remotion
    y(y == -1) = [];

end
            