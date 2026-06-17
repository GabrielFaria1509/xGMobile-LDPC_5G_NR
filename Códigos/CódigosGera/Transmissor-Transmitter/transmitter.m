function [final_message_modulated, H] = transmitter(message, R, E, Q_m, SNR)
    A = length(message);

    CRC = simulador_crc(A);
    msg_crc = [message, CRC];

    B = A + length(CRC);

    BG_number = Base_Graph_selector(A, R);
    Zc = Zc_selector(B,BG_number);
    BG = baseGraph_generator(BG_number, Zc);

    H = H_matrix_generator(BG, Zc);
    G = G_matrix_generator(H);

    msg_filler = filler_bits(msg_crc, G);
    c = codeword_generator(msg_filler, G);

    rate_matched = RateMatching(c,BG_number, Zc, E, Q_m, 1);

    final_message_modulated = ModulatorProcess(rate_matched, Q_m, SNR);


