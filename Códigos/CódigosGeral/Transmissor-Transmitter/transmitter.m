function [final_message_modulated, final_message_modulated2, ...
          final_message_modulated3, final_message_modulated4, ...
          BG_number, Zc, B, codeword, H] = ...
          transmitter(transport_block, R, E, Q_m, SNR)

    A = length(transport_block);

    TB_CRC = crc_generator(transport_block);

    TB_with_CRC = [transport_block, TB_CRC];

    B = A + length(TB_CRC);

    BG_number = Base_Graph_selector(A, R);

    Zc = Zc_selector(B, BG_number);

    BG = baseGraph_generator(BG_number, Zc);

    H = H_matrix_generator(BG, Zc);

    G = G_matrix_generator_2(H, Zc);

    Kb = (BG_number == 1)*22 + (BG_number == 2)*10;
    Kcb = Kb*Zc;

    code_block_with_filler = filler_bits(TB_with_CRC,Kcb);

    codeword = codeword_generator(code_block_with_filler, G);

    rate_matched_RV1 = RateMatching(codeword, BG_number, Zc, E, Q_m, 1);
    rate_matched_RV2 = RateMatching(codeword, BG_number, Zc, E, Q_m, 2);
    rate_matched_RV3 = RateMatching(codeword, BG_number, Zc, E, Q_m, 3);
    rate_matched_RV4 = RateMatching(codeword, BG_number, Zc, E, Q_m, 4);

    final_message_modulated = ModulatorProcess(rate_matched_RV1, Q_m, SNR);
    final_message_modulated2 = ModulatorProcess(rate_matched_RV2, Q_m, SNR);
    final_message_modulated3 = ModulatorProcess(rate_matched_RV3, Q_m, SNR);
    final_message_modulated4 = ModulatorProcess(rate_matched_RV4, Q_m, SNR);

end