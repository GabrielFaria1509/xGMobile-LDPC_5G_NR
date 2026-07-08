function decoded_blocks = codeBlockDecoding(dematched_blocks, C, K_perblock, H, max_iter)
    decoded_blocks = cell(1, C);
    
    for i = 1 : C
        llr_block = dematched_blocks{i};
        
        % 1. Blindagem de Entrada: O LLR tem o tamanho exato das colunas de H?
        if length(llr_block) ~= size(H, 2)
            fprintf('[ERRO LDPC] Bloco %d: Incompatibilidade. LLR tem %d bits, H espera %d colunas.\n', i, length(llr_block), size(H, 2));
            % Preenche com zeros para não travar o sistema e forçar a falha no CRC
            decoded_blocks{i} = zeros(1, K_perblock); 
            continue;
        end
        
        % 2. Decodificação (usando o nosso NMSA otimizado)
        estimated_bits = sum_product_decoding(H, llr_block, max_iter);
        
        % 3. Blindagem de Saída: O decodificador devolveu bits suficientes?
        if length(estimated_bits) >= K_perblock
            clean_block = estimated_bits(1:K_perblock);
        else
            fprintf('[ERRO LDPC] Bloco %d: Decodificador falhou. Retornou %d bits (esperado %d).\n', i, length(estimated_bits), K_perblock);
            clean_block = zeros(1, K_perblock);
        end
        
        decoded_blocks{i} = clean_block;
    end
end