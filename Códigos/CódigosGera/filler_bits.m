function [u, F] = FillerBits(mensagem, G)
    % Extraio capacidade de informação da matriz G
    k_G = height(G);
    
    B = length(mensagem); % Pacote de dados
    
    if B ~= k_G
        F = k_G - B;
        
        if F < 0
            error("The pack is larger than the matrix. Increase o Zc.");
        end
        
        filler_bits = -1*ones(1, F); % Vetor para concatenar na mensagem
        % Marcados como -1(equivalente NULL) temporariamente para permitir a multiplicação com G
        mensagem = [mensagem, filler_bits];
        
    end

    mensagem_camuflada = mensagem;

    %%crio uma máscara,onde for -1 troco para 0 para poder ter a
    %%multiplcação(u*G)
    mensagem_camuflada(mensagem == -1) = 0;
    
    %u é o nome dado para o array que contém a mensagem e os filler bits
    u = mensagem_camuflada;
end