function [final_message_modulated, final_message_modulated2, final_message_modulated3, final_message_modulated4,BG_number, Zc, B, c, H] = transmitter_BER(message, E, Q_m, SNR, BG_number, Zc, H, G)
        A = length(message);
    
        
        CRC = crc_generator(A);
        msg_crc = [message, CRC];
    
        B = A + length(CRC);

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
  