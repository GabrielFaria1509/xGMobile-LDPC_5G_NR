function encoded_blocks = codeBlockEncoding(blocks_filled,C,G)

    encoded_blocks = cell(1,C);

    for i = 1:C
        block = blocks_filled{i};

        codeword_per_block = codeword_generator(block,G);
        encoded_blocks{i} = codeword_per_block;
    end
end