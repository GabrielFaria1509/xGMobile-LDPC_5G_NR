function [code_blocks, C, K_prime, L] = codeBlockSegmentation(TB_with_CRC, BG_number)

    B = length(TB_with_CRC);

    if BG_number == 1
        K_cb = 8448;
    else
        K_cb = 3840;
    end

    if B > K_cb
        L = 24;
        C = ceil(B / (K_cb - L));
        K_prime = ceil((B + C * L) / C);
    else
        L = 0;
        C = 1;
        K_prime = B;
    end

    code_blocks = cell(1, C);

    for i = 1:C

        CB_payload_size = K_prime - L;

        start_idx = (i - 1) * CB_payload_size + 1;

        end_idx = min(i * CB_payload_size, B);

        code_blocks{i} = TB_with_CRC(start_idx:end_idx);

    end

end