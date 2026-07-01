function [u, F] = filler_bits(mensagem, G)
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
        u = [mensagem, filler_bits];

    else
        F = 0;
        u = mensagem; % No filler bits needed, just return the original message
        
    end
end