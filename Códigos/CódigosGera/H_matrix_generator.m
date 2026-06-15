function H = H_matrix_generator(BG, Zc)
    [m, n] = size(BG);
    
    %Cria a matriz H vazia
    H = zeros([m*Zc, n*Zc]);

    for j = 1:m
        for i = 1:n
           
            if BG(j,i) ~= -1
                %cria o bloco identidade e circula ele
                bloco = circshift(eye(Zc), [0, BG(j,i)]);
                H((j-1)*Zc+1:j*Zc, (i-1)*Zc+1:i*Zc) = bloco;
            end
        end
    end

    H = sparse(H);