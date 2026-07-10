function code_blocks_with_crc = codeblockcrcimplementation(code_blocks, C)

    code_blocks_with_crc = cell(1, C);

    for i = 1:C

        code_block = code_blocks{i};

        if C > 1
            CB_CRC = crc_generator(code_block, "24B");
            processed_code_block = [code_block, CB_CRC];
        else
            processed_code_block = code_block;
        end

        code_blocks_with_crc{i} = processed_code_block;

    end
end