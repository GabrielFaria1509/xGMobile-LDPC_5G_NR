function blocks = codeBlockSegmentation(msg_crc,BG_number)
    B = length(msg_crc);

    if BG_number == 1
        K_cb = 8448;
    else
        K_cb = 3840;
    end

    if B > K_cb
        L = 24;
        C = ceil(B / (K_cb - L));
        K_perblock = ceil((B + C * L) / C);
    else
        L = 0;
        C = 1;
        K_perblock = B;
    end

    blocks = cell(1,C);

        for i = 1 : C
            block_size = K_perblock - L;
            beg = (i-1) * block_size + 1;
            ending = min(i*block_size,B);

            blocks{i} = msg_crc(beg:ending);

        end

end

