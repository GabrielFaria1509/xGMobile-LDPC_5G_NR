function [z, I, L] = sumProductDecoding(r, H, max_iter)
    % =========================================================================
    % Algoritmo 4: Sum-Product Decoding (Soft-Decision)
    % Entradas:
    %   r        : Vetor LLR (Log-Likelihood Ratios) recebido do canal (a priori)
    %   H        : Matriz de paridade LDPC
    %   max_iter : Número máximo de iterações permitidas
    % Saídas:
    %   z        : Vetor de bits decodificado (Hard Decision final, 0 ou 1)
    %   I        : Número de iterações executadas
    %   L        : Vetor LLR total (a posteriori) de cada bit
    % =========================================================================
    
    [m, n] = size(H);
    I = 0;
    
    % M(j,i) será a mensagem probabilística do bit 'i' para a equação 'j'.
    M = zeros(m, n);
    for i = 1:n
        % Encontra as equações (linhas) conectadas a este bit 'i'
        Ai = find(H(:, i) == 1);
        for k = 1:length(Ai)
            j = Ai(k);
            % No tempo zero, o bit só conhece o que veio da antena (o LLR r_i).
            % Então ele repassa essa mesma crença para todas as suas equações.
            M(j, i) = r(i);
        end
    end
    
    % Matriz E(j,i) guardará as mensagens das equações (j) para os bits (i)
    E = zeros(m, n);
    Finished = false;
    
    while ~Finished
        
        % =====================================================================
        % Step 1: Check messages (Nós de Verificação calculam as probabilidades)
        % =====================================================================
        for j = 1:m
            % Encontra os bits conectados a esta equação 'j'
            Bj = find(H(j, :) == 1);
            for k = 1:length(Bj)
                i = Bj(k);
                
                % Pega todos os vizinhos, exceto o próprio bit 'i'
                outros_bits = Bj(Bj ~= i);
                
                % Aplica a tangente hiperbólica (tanh) nas mensagens recebidas
                % divididas por 2, e multiplica todas elas (produtório)
                produtorio = prod(tanh(M(j, outros_bits) / 2));
                
                % Dica de Engenharia: Em canais com ruído extremo, o produtório 
                % pode arredondar para exatamente 1 ou -1 no MATLAB, gerando log(0).
                % Para simulações perfeitas, o MATLAB processa isso gerando 'Inf' ou '-Inf'.
                E(j, i) = log((1 + produtorio) / (1 - produtorio));
            end
        end % FIM DO STEP 1 
        
        % =====================================================================
        % Step 2 & Test (Apurando as probabilidades totais e checando parada)
        % =====================================================================
        L = zeros(1, n);
        z = zeros(1, n);
        
        for i = 1:n
            % Equações conectadas ao bit 'i'
            Ai = find(H(:, i) == 1);
            
            % O bit soma todas as opiniões das equações com a sua crença original
            L(i) = sum(E(Ai, i)) + r(i);
            
            % Tomada de decisão Hard (Transforma LLR em 0 ou 1)
            % Se LLR <= 0, o bit é 1. Se LLR > 0, o bit é 0.
            if L(i) <= 0
                z(i) = 1;
            else
                z(i) = 0;
            end
        end
        
        % Condição de Parada
        sindrome = mod(H * z', 2);
        
        if all(sindrome == 0) || (I >= max_iter)
            Finished = true;
        else
            % else (Ainda há erros, vamos atualizar as mensagens)
            I = I + 1;
            
            for i = 1:n
                Ai = find(H(:, i) == 1);
                for k = 1:length(Ai)
                    j = Ai(k);
                    
                    % Encontra as mensagens de TODAS as outras equações, exceto 'j'
                    outros_checks = Ai(Ai ~= j);
                    
                    % O bit manda para a equação 'j' a soma das opiniões 
                    % das OUTRAS equações + a sua crença original.
                    M(j, i) = sum(E(outros_checks, i)) + r(i);
                end
            end
        end
        
    end % fim do loop while
end % fim da função