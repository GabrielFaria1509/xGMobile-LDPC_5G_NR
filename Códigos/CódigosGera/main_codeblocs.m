%% ========================================================================
%% 5G NR SIMULATOR - LDPC TRANSCEIVER (xGMobile Project - Inatel)
%% ========================================================================
clear; clc; close all;

% Add all subfolders (Transmitter, Receiver, etc.) to MATLAB path
% IMPORTANT: Make sure that MATLAB "Current Folder" is the 'CódigosGera' folder
addpath(genpath(pwd));


%% 1. GENERAL SYSTEM PARAMETERS

% You can modify these values later to test the channel limits

A = 100;          % Original message size (bits)
R = 1/3;           % Code Rate
E = 1000;         % Total resources after Rate Matching (bits)
Q_m = 2;           % Modulation Order (2 = QPSK)
EbN0_dB = 1;%Equal as SNR        % Channel Signal-to-Noise Ratio (Decrease to force HARQ)
                    


fprintf('==========================================================\n');
fprintf(' Starting 5G NR LDPC Simulation \n');
fprintf(' Message Size (A)      : %d bits\n', A);
fprintf(' Modulation (Q_m)      : %d\n', Q_m);
fprintf(' SNR                   : %d dB\n', EbN0_dB);
fprintf('==========================================================\n');


%% 2. ORIGINAL MESSAGE GENERATION

transport_block = message_generator(A);


%% 3. TRANSMITTER AND CHANNEL (Pipeline)

fprintf('\n[TX] Processing Transmitter...\n');

% transmitterfull performs encoding, modulation and noise addition
% according to the defined SNR value
TB_CRC = crc_generator(transport_block);
TB_with_CRC = [transport_block, TB_CRC];
B = length(TB_with_CRC);


%%
BG_number = Base_Graph_selector(A,R);

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
    code_blocks_with_filler = codeBlockFiller(code_blocks_with_crc, C, G);

    % 4. LDPC Encoding
    encoded_code_blocks = codeBlockEncoding(code_blocks_with_filler, C, G);
     
    for i = 1:C

        filler_indices = find(code_blocks_with_filler{i} == -1);

        encoded_code_blocks{i}(filler_indices) = -1;

    end


fprintf('[TX] Transmission completed. Extracted parameters:\n');

fprintf('     -> Code Blocks (C) : %d\n', C);
fprintf('     -> Base Graph      : %d\n', BG_number);
fprintf('     -> Zc              : %d\n', Zc);

 %% === DEBUG INFORMATION ===

    fprintf('\n--- PIPELINE DEBUG ---\n');
    fprintf('TB with CRC length        : %d\n', length(TB_with_CRC));
    fprintf('Zc                        : %d\n', Zc);
    fprintf('Generator matrix G        : %d x %d\n', size(G,1), size(G,2));
    fprintf('Code Block with filler    : %d\n', length(code_blocks_with_filler{1}));
    fprintf('Encoded Code Block        : %d\n', length(encoded_code_blocks{1}));
    fprintf('Required puncturing       : %d bits\n', 2 * Zc);
    fprintf('--------------------------\n\n');

    % 5. Rate Matching
    [rate_matched_RV1, rate_matched_RV2, ...
     rate_matched_RV3, rate_matched_RV4] = ...
     codeBlockRateMatching(encoded_code_blocks, C, E, BG_number, Zc, Q_m);

     % Modulation
    final_message_modulated  = ModulatorProcess(rate_matched_RV1, Q_m, EbN0_dB,R);
    final_message_modulated2 = ModulatorProcess(rate_matched_RV2, Q_m, EbN0_dB,R);
    final_message_modulated3 = ModulatorProcess(rate_matched_RV3, Q_m, EbN0_dB,R);
    final_message_modulated4 = ModulatorProcess(rate_matched_RV4, Q_m, EbN0_dB,R);

    % Prepare the received signals for further processing
    rx_1 = final_message_modulated;
    rx_2 = final_message_modulated2;
    rx_3 = final_message_modulated3;
    rx_4 = final_message_modulated4;


%% 4. RECEPTION, DECODING AND HARQ

fprintf('\n[RX] Starting Receiver Processing (HARQ)...\n');

harq_transmissions = {rx_1, rx_2, rx_3, rx_4};


% Defines the Transport Block CRC type based on original message size A

if A > 3824

    transport_crc_type = "24A";

else

    transport_crc_type = "16";

end


% Extracts the size of each code block (K_perblock) using segmentation
% with the selected Base Graph

[~, ~, K_perblock, ~] = codeBlockSegmentation(zeros(1, B), BG_number);


if C > 1

    L = 24; % 24-bit CRC added to each code block

else

    L = 0;  % No additional CRC when only one code block exists

end


K_actual = ceil(B / C) + L;


harq_buffer = -1;

max_iter = 50;

absolute_success = false;


%% ================= HARQ LOOP =================

for attempt = 1 : 4

    fprintf('\n--- STARTING ATTEMPT %d/4 (RV %d) ---\n', attempt, attempt);


    rx_signal = harq_transmissions{attempt};


    rx_llr = ReceiverEntry(rx_signal, Q_m, EbN0_dB,R);


    % Conditional Buffer Execution
    % Enables nargin < 9 behavior on the first attempt

    if attempt == 1

        dematched_blocks = codeBlockRateDematching(rx_llr, C, E, BG_number, Zc, Q_m, K_actual, attempt);

    else

        dematched_blocks = codeBlockRateDematching(rx_llr, C, E, BG_number, Zc, Q_m, K_actual, attempt, harq_buffer);

    end


    % Stores processed blocks for HARQ soft combining

    harq_buffer = dematched_blocks;


    % LDPC Channel Decoding

    decoded_blocks = codeBlockDecoding(dematched_blocks, C, K_perblock, H, max_iter);


    % Code Block Desegmentation and CRC-24B validation

    [msg_rx_crc, crc_cb_pass] = codeBlockDesegmentation(decoded_blocks, C, B);


    % Separation of Payload and Transport CRC validation (24A or 16)

    received_message = msg_rx_crc(1 : A);

    received_crc      = msg_rx_crc(A + 1 : end);

    calculated_crc    = crc_generator(received_message, transport_crc_type);


    % --- FINAL INTEGRITY CHECK ---

    if isequal(received_crc(:).', calculated_crc(:).')


        fprintf('[SUCCESS] Transport CRC (%s) Valid on attempt %d!\n', transport_crc_type, attempt);


        real_errors = sum(transport_block(:) ~= received_message(:));


        if real_errors == 0

            fprintf('[ABSOLUTE SUCCESS] Message recovered with 0 bit errors!\n');

            absolute_success = true;

            break;


        else

            fprintf('[WARNING] CRC passed, but message contains %d divergent bits (False Positive).\n', real_errors);

        end


    else


        number_of_errors = sum(received_message(:) ~= transport_block(:));


        fprintf('[FAILURE] Invalid CRC. Incorrect bits on attempt %d: %d bits.\n', attempt, number_of_errors);


    end

end


if ~absolute_success

    fprintf('\n[CRITICAL FAILURE] Unable to recover packet after 4 transmissions.\n');

end


fprintf('==========================================================\n');