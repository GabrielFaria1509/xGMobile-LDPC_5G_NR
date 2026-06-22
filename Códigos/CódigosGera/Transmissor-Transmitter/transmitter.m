function [final_message_modulated, final_message_modulated2, final_message_modulated3, final_message_modulated4,BG_number, Zc, B, c, H] = transmitter(message, R, E, Q_m, SNR)
        A = length(message);
    
        CRC = simulador_crc(A);
        msg_crc = [message, CRC];
    
        B = A + length(CRC);
    
        BG_number = Base_Graph_selector(A, R);
        Zc = Zc_selector(B,BG_number);
        BG = baseGraph_generator(BG_number, Zc);
    
        H = H_matrix_generator(BG, Zc);
        spy(H);
        title("Matriz H");
        
        
        G = G_matrix_generator_2(H,Zc);

        spy(G);
        title("Matriz G");
    
        msg_filler = filler_bits(msg_crc, G);
        c = codeword_generator(msg_filler, G);
    
        rate_matched = RateMatching(c,BG_number, Zc, E, Q_m, 1);
        rate_matched2 = RateMatching(c,BG_number, Zc, E, Q_m, 2);
        rate_matched3 = RateMatching(c,BG_number, Zc, E, Q_m, 3);
        rate_matched4 = RateMatching(c,BG_number, Zc, E, Q_m, 4);

    
        final_message_modulated = ModulatorProcess(rate_matched, Q_m, SNR);
        final_message_modulated2 = ModulatorProcess(rate_matched2, Q_m, SNR);
        final_message_modulated3 = ModulatorProcess(rate_matched3, Q_m, SNR);
        final_message_modulated4 = ModulatorProcess(rate_matched4, Q_m, SNR);
  