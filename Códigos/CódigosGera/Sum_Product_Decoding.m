function z = Sum_Product_Decoding(H, r, I_maximo)
    [m, n] = size(H);
    
    B = cell(1,m);
    A = cell(1,n);
    
    for j = 1:m
        B{j} = find(H(j,:) == 1);
    end
    
    for i = 1:n
        A{i} = find(H(:,i) == 1)';
    end
    
    M = sparse(zeros(m, n));

    for j = 1:m
        for i = B{j}
            M(j,i) = r(i);
        end
    end
    
    for I = 1:I_maximo
       
        E = sparse(zeros(m, n));
        
        for j = 1:m
            for i = B{j}
                vizinhos = M(j, B{j}(B{j} ~= i));

                sinal = prod(sign(vizinhos));

                valor_min = min(abs(vizinhos));

                E(j,i) = sinal*valor_min;
            end
        end
        
    
        L = zeros(1,n);
        z = zeros(1,n);
        
        for i = 1:n
            L(i) = r(i) + sum(E(A{i}, i));
            z(i) = L(i) <= 0;
        end
        
        if all(mod(H*z', 2) == 0)
            break
        end
        
        for i = 1:n
            for j = A{i}
                M(j,i) = r(i) + sum(E(A{i}(A{i} ~= j), i));
            end
        end
    end

    if any(mod(H*z', 2) ~= 0)
        %display('Não foi possível decodificar')
    end

    