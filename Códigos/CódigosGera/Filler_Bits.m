function [filler_bits, F] = Filler_Bits(mensagem, G)
    k = height(G);
    
    B = length(mensagem); % Pacote de dados
    
    if B ~= k
        F = k - B;
        
        if F < 0
            error("Tamanho da mensagem não suportada");
        end
        
        filler_bits = zeros(1, F);
        filler_bits = [mensagem, filler_bits];
    else
        filler_bits = mensagem;
    end
end