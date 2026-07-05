function encoded_blocks = codeBlockEncoding(blocks_filled, C, G)
    encoded_blocks = cell(1,C);
    for i = 1:C
        block = blocks_filled{i};
        
        % CONVERSÃO TEMPORÁRIA: Transforma os -1 (NULL) em 0 para a álgebra de GF(2)
        block_for_math = block;
        block_for_math(block_for_math == -1) = 0;
        
        % Codifica com o bloco convertido
        encoded_blocks{i} = codeword_generator(block_for_math, G);
    end
end