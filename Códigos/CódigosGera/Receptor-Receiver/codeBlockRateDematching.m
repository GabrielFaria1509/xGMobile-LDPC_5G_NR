function dematched_blocks = codeBlockRateDematching(full_llr, C, E, BG_number, Zc, Q_m, K_perblock, attempt, buffer_in)
    
    % Inicializa o buffer vazio (tentativa 1)
    if nargin < 9 || isempty(buffer_in)
        buffer_in = num2cell(-1 * ones(1, C)); 
    end
    
    dematched_blocks = cell(1, C);
    
    %% CORREÇÃO: Divisão Baseada em Símbolos (Garante múltiplos de Q_m)
    symbol_chunks = floor(E / Q_m);       % Total de símbolos disponíveis
    chunks_base = floor(symbol_chunks / C); % Símbolos por bloco
    chunks_rest = mod(symbol_chunks, C);    % Símbolos extras a distribuir
    
    E_base = chunks_base * Q_m;           % Bits base por bloco
    
    pointer = 1;
    for i = 1 : C
        % Os primeiros 'chunks_rest' blocos ganham 1 símbolo extra (Q_m bits)
        if (i - 1) < chunks_rest
            E_i = E_base + Q_m; 
        else
            E_i = E_base;
        end
        
        % Fatiamento exato do vetor
        sub_llr = full_llr(pointer : pointer + (E_i - 1)); 
        pointer = pointer + E_i;
        
        % Processamento HARQ e De-Rate Matching
        bloco_buffer = buffer_in{i};
        output_block = derate_matching(sub_llr, BG_number, Zc, Q_m, K_perblock, attempt, bloco_buffer);
        
        dematched_blocks{i} = output_block;
    end
end