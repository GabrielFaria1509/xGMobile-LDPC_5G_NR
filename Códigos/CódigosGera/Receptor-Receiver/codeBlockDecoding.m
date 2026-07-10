function decoded_blocks = codeBlockDecoding(dematched_blocks, C, K_perblock, H, max_iter)

    decoded_blocks = cell(1, C);


    for i = 1 : C

        llr_block = dematched_blocks{i};


        % 1. Input protection: Does the LLR size match the number of H columns?

        if length(llr_block) ~= size(H, 2)

            fprintf('[LDPC ERROR] Block %d: Size mismatch. LLR has %d bits, but H expects %d columns.\n', ...
                i, length(llr_block), size(H, 2));


            % Fill with zeros to avoid system interruption and force CRC failure

            decoded_blocks{i} = zeros(1, K_perblock);

            continue;

        end



        % 2. LDPC Decoding (using the optimized NMSA decoder)

        estimated_bits = sum_product_decoding(H, llr_block, max_iter);



        % 3. Output protection: Did the decoder return enough bits?

        if length(estimated_bits) >= K_perblock

            clean_block = estimated_bits(1:K_perblock);


        else

            fprintf('[LDPC ERROR] Block %d: Decoder failed. Returned %d bits (expected %d).\n', ...
                i, length(estimated_bits), K_perblock);


            clean_block = zeros(1, K_perblock);

        end



        decoded_blocks{i} = clean_block;

    end

end