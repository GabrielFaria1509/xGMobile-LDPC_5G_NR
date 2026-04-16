% -1 será um bit apagado
% Erasure decoding algorithm
function [M, I,success] = erasureDecoding(y, H, max_iter)
    % y: vetor recebido
    % H: matriz de paridade
    % max_iter: número máximo de iterações
    % M: vetor de bits decodificado
    % I: número de iterações que o algoritmo levou para corrigir
    
    % m == equações de paridade (linhas)
    % n == nós de variável (colunas)
    [m, n] = size(H);
    I = 0; % iniciando variável para num de iterações
    
    % inicialização do vetor
    M = y;
    
    % Criando a matriz E que vai guardar as mensagens dos Check Nodes
    % Inicializamos com -1 (apagado/unknown).
    E = -1 * ones(m, n);
    
    % controle de loop
    Finished = false;
    
    while ~Finished
        I = I + 1; % aumentando contador
        
        % =================================================================
        % Step 1: Check messages (Nós de Verificação geram as respostas)
        % =================================================================
        for j = 1 : m
            % Encontra os índices dos bits conectados a esta equação j.
            Bj = find(H(j, :) == 1);
            
            % Separa quem é 'apagado' (-1) e quem é 'conhecido'
            apagados = Bj(M(Bj) == -1);
            conhecidos = Bj(M(Bj) ~= -1);
            
            % Se houver EXATAMENTE UM bit apagado nesta equação, ela resolve!
            if length(apagados) == 1
                % O índice 'i' é exatamente a posição 1 do vetor de apagados solitário
                i = apagados(1); 
                
                % O bit que falta é o resto da divisão por 2 da soma dos conhecidos
                soma_conhecidos = sum(M(conhecidos));
                E(j, i) = mod(soma_conhecidos, 2);
                
                % A equação manda -1 ('x') para quem já é conhecido
                E(j, conhecidos) = -1;
            else
                % Se tem 0 apagados ou 2+ apagados, manda -1 para todos
                E(j, Bj) = -1;
            end
        end
        
        % =================================================================
        % Step 2: Bit messages (Nós de Variável atualizam seus valores)
        % =================================================================
        for i = 1:n
            % Só tentamos atualizar se o bit estiver apagado (-1)
            if M(i) == -1
                % Puxamos todas as respostas que as equações mandaram para ele
                mensagens_recebidas = E(:, i);
                
                % Filtramos apenas as respostas válidas (diferentes de -1)
                respostas_validas = mensagens_recebidas(mensagens_recebidas ~= -1);
                
                % Se recebemos pelo menos UMA resposta válida, atualizamos
                if ~isempty(respostas_validas)
                    M(i) = respostas_validas(1);
                end
            end
        end
        
        % =================================================================
        % Condição de Parada
        % =================================================================
        todos_resolvidos = ~any(M == -1);
        
        % O algoritmo para se resolveu tudo OU atingiu o limite de tentativas
        if todos_resolvidos || (I >= max_iter)
            Finished = true;
        end
        
    end % Fim do loop principal

    if any(M == -1)
        % Se saiu do loop e ainda tem -1, caiu em um Stopping Set
        success = false; 
    else
        % Se não tem mais -1, checa se a palavra é válida (Síndrome = 0)
        sindrome = mod(H * M', 2);
        if all(sindrome == 0)
            success = true; % Palavra válida e perfeita!
        else
            success = false; % Convergiu, mas para uma palavra inválida
        end
    end

    
    
end % Fim da função
