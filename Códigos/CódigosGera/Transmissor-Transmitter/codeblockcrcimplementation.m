function blocks_with_crc = codeblockcrcimplementation(blocks,C)
    
    blocks_with_crc = cell(1,C);

    for i = 1 : C
        codeblock = blocks{i};

        if C > 1 
            codeblockscrc = crc_generator(codeblock,"24B");

            processed_block = [codeblock,codeblockscrc];


        else
            processed_block = codeblock;
        end
        
        blocks_with_crc{i} = processed_block;
    end
end



