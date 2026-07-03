function [final_block1, final_block2, final_block3, final_block4] = codeBlockRateMatching(encoded_blocks, C, E, BG_number, Zc, Q_m)
        
    % Inicializa as variáveis de saída vazias
    final_block1 = [];
    final_block2 = [];
    final_block3 = [];
    final_block4 = [];
    
    E_base = floor(E/C);
    E_rest = mod(E,C);
    
    for i = 1 : C
        codeword = encoded_blocks{i};
        
        if (i - 1) < E_rest
            E_i = E_base + 1;
        else
            E_i = E_base;
        end
        
        block_rv1 = RateMatching(codeword, BG_number, Zc, E_i, Q_m, 1);
        block_rv2 = RateMatching(codeword, BG_number, Zc, E_i, Q_m, 2);
        block_rv3 = RateMatching(codeword, BG_number, Zc, E_i, Q_m, 3);
        block_rv4 = RateMatching(codeword, BG_number, Zc, E_i, Q_m, 4);
        
        
        final_block1 = [final_block1, block_rv1];
        final_block2 = [final_block2, block_rv2];
        final_block3 = [final_block3, block_rv3];
        final_block4 = [final_block4, block_rv4];
    end
end