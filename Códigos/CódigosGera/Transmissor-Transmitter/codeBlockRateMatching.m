function [final_block1, final_block2, final_block3, final_block4] = codeBlockRateMatching(encoded_blocks, C, E, BG_number, Zc, Q_m)
        
    % Inicializa as variáveis de saída vazias
    final_block1 = [];
    final_block2 = [];
    final_block3 = [];
    final_block4 = [];
    
    %% CORREÇÃO: Divisão Baseada em Símbolos (Garante múltiplos de Q_m)
    symbol_chunks = floor(E / Q_m);       % Total de símbolos disponíveis
    chunks_base = floor(symbol_chunks / C); % Símbolos por bloco
    chunks_rest = mod(symbol_chunks, C);    % Símbolos extras a distribuir
    
    E_base = chunks_base * Q_m;           % Bits base por bloco
    
    for i = 1 : C
        codeword = encoded_blocks{i};
        
        % Os primeiros 'chunks_rest' blocos ganham 1 símbolo extra (Q_m bits)
        if (i - 1) < chunks_rest
            E_i = E_base + Q_m;
        else
            E_i = E_base;
        end
        
        % Chamada da função de Rate Matching para cada Redundancy Version (RV)
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