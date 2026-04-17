function M = Bit_Flipping_Decoding(H, y, I_maximo)
    [m, n] = size(H);
    
    B = {};
    A = {};
    
    %Cria os sets A e B
    for j = 1:m
        B{j} = find(H(j,:) == 1);
    end
    
    for i = 1:n
        A{i} = find(H(:,i) == 1)';
    end

    M = y;
    
    Iteracao = 0;
    
    while Iteracao < I_maximo
        if all(mod(H*M', 2) == 0) %dedecta sindrome
            break
        end
    
        r = M;
    
        for i = 1:n
            E = [];
            for j = A{i}
                vizinhos = B{j};
                vizinhos(vizinhos == i) = [];
                E = [E mod(sum(r(vizinhos)), 2)];
            end
            maioria = sum(E) > length(E)/2;
            if sum(E) ~= length(E)/2 && maioria ~= M(i)
                M(i) = ~M(i);
            end
        end
        Iteracao = Iteracao + 1;
    end