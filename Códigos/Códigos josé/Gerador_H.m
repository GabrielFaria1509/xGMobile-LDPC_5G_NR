function H = Gerador_H(BG, Z)
    [m, n] = size(BG);
    
    H = zeros([m*Z, n*Z]);
    
    for j = 1:m
        for i = 1:n
            
            if BG(j,i) ~= -1
                bloco = circshift(eye(Z), [0, BG(j,i)]);
            else
                bloco = zeros(Z);
            end
            
            H((j-1)*Z+1:j*Z, (i-1)*Z+1:i*Z) = bloco;
            
        end
    end