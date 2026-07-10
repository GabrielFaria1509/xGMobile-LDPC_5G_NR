function code_blocks_with_filler = codeBlockFiller(code_blocks_with_crc, C, G)

    code_blocks_with_filler = cell(1, C);

    for i = 1:C

        code_block = code_blocks_with_crc{i};

        processed_code_block = filler_bits(code_block, G);

        code_blocks_with_filler{i} = processed_code_block;

    end

end