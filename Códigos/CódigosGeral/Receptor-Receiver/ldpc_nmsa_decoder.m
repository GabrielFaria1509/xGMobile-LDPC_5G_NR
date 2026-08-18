function llr = ldpc_nmsa_decoder(H, r, I_maximo, B, A)
    % Nota: Esta função implementa o Normalized Min-Sum Algorithm (NMSA), 
    % que é o padrão de hardware para decodificadores LDPC 5G.
    
    [m, n] = size(H);
    
    % Inicialização da matriz de mensagens M
    M = zeros(m, n);
    for j = 1:m
        for i = B{j}
            M(j,i) = r(i);
        end
    end
    
    % Pré-alocação da matriz E com a mesma estrutura esparsa de H
    % Isso evita o gargalo de realocar memória a cada iteração
    E = zeros(m, n); 
    
    alpha = 0.75; % Fator de atenuação para o Normalized Min-Sum (Melhora o ganho de SNR)
    
    %% ================= O LAÇO DE DECODIFICAÇÃO =================
    for I = 1:I_maximo
        
        % 1. Atualização dos Check Nodes (Horizontal)
        for j = 1:m
            vizinhanca = B{j};
            valores = M(j,vizinhanca);

            valores_abs = abs(valores);
            [valor_min1, idxMin] = min(valores_abs);
            valores_abs(idxMin) = inf;
            valor_min2 = min(valores_abs);


            sinais = sign(valores);
            sinais(sinais==0)=1;
            
            produto_total = prod(sinais);
            
            for k = 1:numel(vizinhanca)
                i = vizinhanca(k);

                sinal = produto_total*sinais(k);

                if k == idxMin
                    valor_min = valor_min2;
                else
                    valor_min = valor_min1;
                end
                % Aplicação do Min-Sum com fator de normalização
                E(j,i) = sinal * valor_min * alpha; 
            end
        end
        
        L = zeros(1,n);
        llr = zeros(1,n);
        
        % 2. Atualização dos Variable Nodes e Decisão Soft (Vertical)
        for i = 1:n
            L(i) = r(i) + sum(E(A{i}, i));
            llr(i) = L(i) <= 0; % Decisão Hard
        end
        
        % 3. Checagem de Síndrome (Early Exit)
        if all(mod(H*llr', 2) == 0)
            break
        end
        
        % 4. Atualização das mensagens para a próxima iteração
        for i = 1:n
            for j = A{i}
                M(j,i) = r(i) + sum(E(A{i}(A{i} ~= j), i));
            end
        end
    end
    
    if any(mod(H*llr', 2) ~= 0)
        % Se chegar aqui, o decodificador falhou e atingiu o I_maximo
        % O pacote será descartado e solicitará HARQ
    end
end