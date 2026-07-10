function encoded_code_blocks = codeBlockEncoding(code_blocks_with_filler, C, G)

    encoded_code_blocks = cell(1, C);

    for i = 1:C

        code_block = code_blocks_with_filler{i};

        % TEMPORARY CONVERSION:
        % Replace filler bits (-1 / NULL) with 0 for the GF(2) operations.
        code_block_GF2 = code_block;
        code_block_GF2(code_block_GF2 == -1) = 0;

        % Encode the processed Code Block
        encoded_code_blocks{i} = codeword_generator(code_block_GF2, G);

    end
end