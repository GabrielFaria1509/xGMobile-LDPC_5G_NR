function [final_message_modulated, final_message_modulated2, ...
          final_message_modulated3, final_message_modulated4, ...
          C, BG_number, Zc, B, H] = ...
          transmitterfull(transport_block, R, E, Q_m, SNR)

    A = length(transport_block);

    TB_CRC = crc_generator(transport_block);

    TB_with_CRC = [transport_block, TB_CRC];

    B = length(TB_with_CRC);

    BG_number = Base_Graph_selector(A, R);

    %% =======================================================
    %% 5G NR TRANSMITTER PIPELINE
    %% =======================================================

    % 1. Code Block Segmentation
    [code_blocks, C, K_prime] = codeBlockSegmentation(TB_with_CRC, BG_number);

    % Lifting size and matrix generation
    Zc = Zc_selector(K_prime, BG_number);

    BG = baseGraph_generator(BG_number, Zc);

    H = H_matrix_generator(BG, Zc);

    G = G_matrix_generator_2(H, Zc);

    % 2. Code Block CRC Attachment
    code_blocks_with_crc = codeblockcrcimplementation(code_blocks, C);

    % 3. Filler Bits Insertion
    Kb = (BG_number == 1)*22 + (BG_number == 2)*10;
    Kcb = Kb*Zc;
    code_blocks_with_filler = codeBlockFiller(code_blocks_with_crc, C, Kcb);

    % 4. LDPC Encoding
    encoded_code_blocks = codeBlockEncoding(code_blocks_with_filler, C, Kcb);

    for i = 1:C

        filler_indices = find(code_blocks_with_filler{i} == -1);

        encoded_code_blocks{i}(filler_indices) = -1;

    end

    %% === DEBUG INFORMATION ===

    fprintf('\n--- PIPELINE DEBUG ---\n');
    fprintf('TB with CRC length        : %d\n', length(TB_with_CRC));
    fprintf('Zc                        : %d\n', Zc);
    fprintf('Generator matrix G        : %d x %d\n', size(G,1), size(G,2));
    fprintf('Code Block with filler    : %d\n', length(code_blocks_with_filler{1}));
    fprintf('Encoded Code Block        : %d\n', length(encoded_code_blocks{1}));
    fprintf('Required puncturing       : %d bits\n', 2 * Zc);
    fprintf('--------------------------\n\n');

    %% =======================================================

    % 5. Rate Matching
    [rate_matched_RV1, rate_matched_RV2, ...
     rate_matched_RV3, rate_matched_RV4] = ...
     codeBlockRateMatching(encoded_code_blocks, C, E, BG_number, Zc, Q_m);

    % Modulation
    final_message_modulated  = ModulatorProcess(rate_matched_RV1, Q_m, SNR);
    final_message_modulated2 = ModulatorProcess(rate_matched_RV2, Q_m, SNR);
    final_message_modulated3 = ModulatorProcess(rate_matched_RV3, Q_m, SNR);
    final_message_modulated4 = ModulatorProcess(rate_matched_RV4, Q_m, SNR);

end