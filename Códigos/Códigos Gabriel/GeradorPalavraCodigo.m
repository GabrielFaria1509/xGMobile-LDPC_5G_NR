function [palavra_codigo, F] = GeradorPalavraCodigo(mensagem, G)
    % Verificar se o tamanho da mensagem bate com a matriz G
    % Extraio capacidade de informação da matriz G
    [k_G, ~] = size(G);
    
    F = 0; % Quantidade de filler bits
    B = length(mensagem); % Pacote de dados
    
    if B ~= k_G
        disp("Tamanho da mensagem menor que a Matriz G");
        disp("Iniciando implementação de filler bits...");
        
        F = k_G - B;
        
        if F < 0
            error("O pacote é maior que a matriz. Aumente o Zc.");
        end
        
        filler_bits = -1*ones(1, F); % Vetor para concatenar na mensagem
        % Marcados como -1(equivalente NULL) temporariamente para permitir a multiplicação com G
        mensagem = [mensagem, filler_bits];
        
        fprintf("Filler bits adicionados: %d\n", F);
    end

    mensagem_camuflada = mensagem;

    %%crio uma máscara,onde for -1 troco para 0 para poder ter a
    %%multiplcação(u*G)
    mensagem_camuflada(mensagem == -1) = 0;
    
    palavra_codigo = mod(mensagem_camuflada* G, 2);

    palavra_codigo(1:k_G) = mensagem;
end