function M = Erasure_Decoding(H, y, I_maximo)
    
    [m, n] = size(H);
    
    B = {};
    A = {};
    
    for j = 1:m
        B{j} = find(H(j,:) == 1);
    end
    
    for i = 1:n
        A{i} = find(H(:,i) == 1)';
    end
    
    Iteracao = 1;
    
    M = y;

    while Iteracao <= I_maximo
        for i = 1:n
            if M(i) == -1
                for j = A{i}
                    vizinhos = B{j};
                    vizinhos(vizinhos == i) = [];
                    if all(M(vizinhos) ~= -1)
                        M(i) = mod(sum(M(vizinhos)), 2);
                        break
                    end
                end
            end
        end
        Iteracao = Iteracao + 1;
        if all(M ~= -1)
            break
        end
    end