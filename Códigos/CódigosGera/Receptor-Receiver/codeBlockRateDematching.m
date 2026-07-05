function dematched_blocks = codeBlockRateDematching(full_llr, C, E, BG_number, Zc, Q_m, K_perblock, attempt, buffer_in)
    
    % Se for a primeira tentativa (attempt == 1), o 'buffer_in' pode não ser passado no main.
    % Nesse caso, criamos um Cell Array onde cada bloco recebe o valor -1 (seu gatilho original).
    if nargin < 9 || isempty(buffer_in)
        buffer_in = num2cell(-1 * ones(1, C)); 
    end
    
    dematched_blocks = cell(1, C);
    E_base = floor(E / C);
    E_rest = mod(E, C); 
    
    pointer = 1;
    for i = 1 : C
        if (i - 1) < E_rest
            E_i = E_base + 1;
        else
            E_i = E_base;
        end
        
        sub_llr = full_llr(pointer : pointer + (E_i - 1)); 
        pointer = pointer + E_i;
        
        % Pega o buffer específico deste bloco da gaveta
        bloco_buffer = buffer_in{i};

        output_block = derate_matching(sub_llr, BG_number, Zc, Q_m, K_perblock, attempt, bloco_buffer);
        
        % Passa o buffer para a função base fazer o Soft Combining
        dematched_blocks{i} = output_block;
    end
end