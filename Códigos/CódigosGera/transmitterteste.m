function [final_message_modulated, final_message_modulated2, final_message_modulated3, final_message_modulated4, C, BG_number, Zc, B, H] = transmitter(message, R, E, Q_m, SNR)
    
    A = length(message);
    
    % Passei a 'message' (os bits) em vez de 'A' (o tamanho) para o gerador
    CRC = crc_generator(message); 
    msg_crc = [message, CRC];

    B = length(msg_crc); % Corrigido para pegar o tamanho exato após o CRC

    BG_number = Base_Graph_selector(A, R);
    
    %% =======================================================
    %% PIPELINE 5G NR (PROCESSAMENTO POR BLOCOS)
    %% =======================================================
    
    % 1. Segmentação (Code Block Segmentation)
    [blocks, C, K_perblock, L] = codeBlockSegmentation(msg_crc, BG_number);
    
    % Definição do Zc e Matrizes (Agora baseadas no bloco fatiado)
    Zc = Zc_selector(K_perblock, BG_number);
    BG = baseGraph_generator(BG_number, Zc);

    H = H_matrix_generator(BG, Zc);
    G = G_matrix_generator_2(H, Zc);

    % 2. Inserção de CRC de Bloco
    blocks_with_crc = codeblockcrcimplementation(blocks, C);
    
    % 3. Preenchimento (Filler Bits)
    blocks_filled = codeBlockFiller(blocks_with_crc, C, G);
    
    % 4. Codificação de Canal (LDPC)
    % 4. Codificação de Canal (LDPC)
    encoded_blocks = codeBlockEncoding(blocks_filled, C, G);
    
    %% === RAIO-X PARA DEBUG ===
    fprintf('\n--- RAIO-X DO PIPELINE ---\n');
    fprintf('Tamanho do msg_crc      : %d\n', length(msg_crc));
    fprintf('Valor de Zc             : %d\n', Zc);
    fprintf('Dimensões da Matriz G   : %d linhas x %d colunas\n', size(G, 1), size(G, 2));
    fprintf('Tamanho do block_filled : %d\n', length(blocks_filled{1}));
    fprintf('Tamanho do codeword (c) : %d\n', length(encoded_blocks{1}));
    fprintf('Puncturing exigido      : %d bits\n', 2 * Zc);
    fprintf('--------------------------\n\n');
    %% =========================
    
    % 5. Rate Matching e Concatenação das Redundancy Versions (RVs)
    [rate_matched1, rate_matched2, rate_matched3, rate_matched4] = codeBlockRateMatching(encoded_blocks, C, E, BG_number, Zc, Q_m);
    
    %% =======================================================

    % Modulação
    final_message_modulated = ModulatorProcess(rate_matched1, Q_m, SNR);
    final_message_modulated2 = ModulatorProcess(rate_matched2, Q_m, SNR);
    final_message_modulated3 = ModulatorProcess(rate_matched3, Q_m, SNR);
    final_message_modulated4 = ModulatorProcess(rate_matched4, Q_m, SNR);
    
end