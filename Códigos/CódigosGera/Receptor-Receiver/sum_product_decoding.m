function z = sum_product_decoding(H, r, I_maximo)
    % Nota: Esta função implementa o Normalized Min-Sum Algorithm (NMSA), 
    % que é o padrão de hardware para decodificadores LDPC 5G.
    
    [m, n] = size(H);
    
    B = cell(1,m);
    A = cell(1,n);
    
    % Mapeamento dos nós de verificação (Check Nodes)
    for j = 1:m
        B{j} = find(H(j,:) == 1);
    end
    
    % Mapeamento dos nós de variável (Variable Nodes)
    for i = 1:n
        A{i} = find(H(:,i) == 1)';
    end
    
    % Inicialização da matriz de mensagens M
    M = sparse(m, n);
    for j = 1:m
        for i = B{j}
            M(j,i) = r(i);
        end
    end
    
    % Pré-alocação da matriz E com a mesma estrutura esparsa de H
    % Isso evita o gargalo de realocar memória a cada iteração
    E = spalloc(m, n, nnz(H)); 
    
    alpha = 0.75; % Fator de atenuação para o Normalized Min-Sum (Melhora o ganho de SNR)
    
    %% ================= O LAÇO DE DECODIFICAÇÃO =================
    for I = 1:I_maximo
        
        % 1. Atualização dos Check Nodes (Horizontal)
        for j = 1:m
            for i = B{j}
                vizinhos = M(j, B{j}(B{j} ~= i));
                sinal = prod(sign(vizinhos) + (vizinhos==0));
                
                % Aplicação do Min-Sum com fator de normalização
                valor_min = min(abs(vizinhos));
                E(j,i) = sinal * valor_min * alpha; 
            end
        end
        
        L = zeros(1,n);
        z = zeros(1,n);
        
        % 2. Atualização dos Variable Nodes e Decisão Soft (Vertical)
        for i = 1:n
            L(i) = r(i) + sum(E(A{i}, i));
            z(i) = L(i) <= 0; % Decisão Hard
        end
        
        % 3. Checagem de Síndrome (Early Exit)
        if all(mod(H*z', 2) == 0)
            break
        end
        
        % 4. Atualização das mensagens para a próxima iteração
        for i = 1:n
            for j = A{i}
                M(j,i) = r(i) + sum(E(A{i}(A{i} ~= j), i));
            end
        end
    end
    
    if any(mod(H*z', 2) ~= 0)
        % Se chegar aqui, o decodificador falhou e atingiu o I_maximo
        % O pacote será descartado e solicitará HARQ
    end
end