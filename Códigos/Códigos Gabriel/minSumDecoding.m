function [z, I, L, success] = minSumDecoding(r, H, max_iter)
    % =========================================================================
    % Algoritmo: Min-Sum Decoding (Simplificação do Sum-Product)
    % Entradas:
    %   r        : Vetor LLR (Log-Likelihood Ratios) recebido do canal
    %   H        : Matriz de paridade LDPC (Base Graph expandido)
    %   max_iter : Número máximo de iterações permitidas
    % Saídas:
    %   z        : Vetor de bits decodificado (Hard Decision final)
    %   I        : Número de iterações executadas
    %   L        : Vetor LLR total (a posteriori) de cada bit
    % =========================================================================
    
    [m, n] = size(H);
    I = 0;
    
    % M(j,i) será a mensagem do bit 'i' para a equação 'j'.
    M = zeros(m, n);
    for i = 1:n
        Ai = find(H(:, i) == 1);
        for k = 1:length(Ai)
            j = Ai(k);
            M(j, i) = r(i);
        end
    end
    
    % Matriz E(j,i) guardará as mensagens das equações (j) para os bits (i)
    E = zeros(m, n);
    Finished = false;
    
    while ~Finished
        
        % =====================================================================
        % Step 1: Check messages (Nós de Verificação - Lógica Min-Sum)
        % =====================================================================
        for j = 1:m
            Bj = find(H(j, :) == 1);
            for k = 1:length(Bj)
                i = Bj(k);
                
                % Pega as mensagens de todos os outros bits conectados à equação j
                outros_bits = Bj(Bj ~= i);
                mensagens_vizinhas = M(j, outros_bits);
                
                % --- A ESSÊNCIA DO MIN-SUM ---
                % 1. Determina o sinal da mensagem (Produto dos sinais dos vizinhos)
                sinal_final = prod(sign(mensagens_vizinhas));
                
                % 2. Determina a magnitude da mensagem (O menor valor absoluto entre vizinhos)
                menor_magnitude = min(abs(mensagens_vizinhas));
                
                % A mensagem de retorno é o sinal vezes a menor magnitude encontrada
                E(j, i) = sinal_final * menor_magnitude;
            end
        end 
        
        % =====================================================================
        % Step 2 & Test (Apurando as probabilidades totais e checando parada)
        % =====================================================================
        L = zeros(1, n);
        z = zeros(1, n);
        
        for i = 1:n
            Ai = find(H(:, i) == 1);
            L(i) = sum(E(Ai, i)) + r(i);
            
            % Tomada de decisão Hard
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
            I = I + 1;
            
            % Atualização das mensagens dos bits para as equações
            for i = 1:n
                Ai = find(H(:, i) == 1);
                for k = 1:length(Ai)
                    j = Ai(k);
                    outros_checks = Ai(Ai ~= j);
                    M(j, i) = sum(E(outros_checks, i)) + r(i);
                end
            end
        end
        
    end 
    
    if all(sindrome == 0)
        success = true;
    else
        success = false;
    end
end