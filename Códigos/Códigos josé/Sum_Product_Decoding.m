function z = Sum_Product_Decoding(H, r, I_maximo)
    [m, n] = size(H);
    
    B = {};
    A = {};
    
    for j = 1:m
        B{j} = find(H(j,:) == 1);
    end
    
    for i = 1:n
        A{i} = find(H(:,i) == 1)';
    end
    
    M = zeros(m, n);

    for j = 1:m
        for i = B{j}
            M(j,i) = r(i);
        end
    end
    
    I = 0;
    
    while I < I_maximo
       
        E = zeros(m, n);
        
        for j = 1:m
            for i = B{j}
                
                prod_val = 1;
                
                for ip = B{j}
                    if ip ~= i
                        prod_val = prod_val * tanh(M(j,ip)/2);
                    end
                end
                
                prod_val = max(min(prod_val, 0.999999), -0.999999);
                
                E(j,i) = log((1 + prod_val) / (1 - prod_val));
            end
        end
        
    
        L = zeros(1,n);
        z = zeros(1,n);
        
        for i = 1:n
            L(i) = r(i) + sum(E(A{i}, i));
            
            if L(i) <= 0
                z(i) = 1;
            else
                z(i) = 0;
            end
        end
        
        if all(mod(H*z', 2) == 0)
            break
        end
        
        for i = 1:n
            for j = A{i}
                
                soma = r(i);
                
                for jp = A{i}
                    if jp ~= j
                        soma = soma + E(jp, i);
                    end
                end
                
                M(j,i) = soma;
            end
        end
        
        I = I + 1;
    end

    if any(mod(H*z', 2) ~= 0)
        error('Não foi possível decodificar')
    end

    