function [M, I] = BitFlipping(y, H, max_iter)
    % Entradas:
    %   y        : Vetor recebido (bits 0 e 1 - Hard Decision)
    %   H        : Matriz de paridade LDPC
    %   max_iter : Número máximo de iterações permitidas
    % Saídas:
    %   M        : Vetor de bits decodificado
    %   I        : Número de iterações executadas
   
    [m, n] = size(H);
    I = 0;
    M = y;
    
    % Criando a matriz E que vai guardar as mensagens dos Check Nodes.
    % E(j,i) será o "voto" da equação j sobre qual deve ser o valor do bit i.
    % Inicializamos com uma matriz de zeros.
    E = zeros(m, n);
    Finished = false;
    
    while ~Finished
        I = I + 1;
        
        for j = 1:m
            % Encontra os índices dos bits ligados a esta equação j (Conjunto B_j).
            Bj = find(H(j, :) == 1);
            
            % Para cada bit ligado a esta equação, a equação vai gerar um "voto"
            % sobre qual deveria ser o valor desse bit.
            for k = 1:length(Bj) % descubro tamanho do vetor de quem é 1 na linha
                i = Bj(k); % Adicionado o ponto e vírgula  
                
                % A equação calcula a paridade com base em TODOS os outros
                % bits ligados a ela, exceto o próprio bit 'i'.
                outros_bits = Bj(Bj ~= i); % vizinhos de k
                
                % Linha 11: Eji = (soma dos outros bits) mod 2
                E(j, i) = mod(sum(M(outros_bits)), 2);
            end
        end
        
        % Step 2: Bit messages (Nós de Variável apuram os votos e atualizam)
        % Criamos um vetor temporário para as atualizações.
        M_novo = M;
        
        for i = 1:n
            % Encontra as equações conectadas a este bit (Conjunto A_i)
            Ai = find(H(:, i) == 1);
            
            % Puxa todos os votos que o bit 'i' recebeu dessas equações
            votos_recebidos = E(Ai, i);
            
            % Conta quantos votos são DIFERENTES do valor atual do bit M(i)
            votos_contra = sum(votos_recebidos ~= M(i));
            
            % Regra de Decisão do Bit-flipping (Maioria)
            if votos_contra > length(Ai)/2
                M_novo(i) = ~M(i);
            end
        end
        
        % Aplica todas as inversões de uma só vez para a próxima iteração
        M = M_novo; % Adicionado o ponto e vírgula
        
        % Condição de Parada (O Teste da Síndrome)
        % Multiplicamos a matriz de paridade H pelo vetor coluna M'
        sindrome = mod(H * M', 2);
        
        % Checa se todos os elementos do vetor de síndrome são zero
        todos_corretos = all(sindrome == 0);
        
        if todos_corretos || (I >= max_iter)
            Finished = true;
        end
        
    end % fim loop
end % Fim da função