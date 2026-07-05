function decoded_blocks = codeBlockDecoding(dematched_blocks, C, K_perblock, H,max_iter)

decoded_blocks = cell(1,C);

for i = 1 : C
    llr_block = dematched_blocks{i};

    estimated_bits = sum_product_decoding(H,llr_block,max_iter);

    clean_block = estimated_bits(1:K_perblock);

    decoded_blocks{i} = clean_block;
end
end

    