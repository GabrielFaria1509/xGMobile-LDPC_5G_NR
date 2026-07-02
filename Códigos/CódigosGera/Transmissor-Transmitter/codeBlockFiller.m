function blocks_filled = codeBlockFiller(blocks_with_crc,C,G)
        
        blocks_filled = cell(1,C);

        for i = 1 : C
            block = blocks_with_crc{i};

            processed_block = filler_bits(block,G);

            blocks_filled{i} = processed_block;
        end
end
