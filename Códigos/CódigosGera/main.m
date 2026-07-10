%% ========================================================================
%% 5G LDPC SIMULATOR - xGMobile (Complete Integration)
%% ========================================================================
% This script orchestrates the communication between the Transmitter and
% Receiver, simulating packet transmission, channel noise effects, and HARQ
% retransmissions.

clear; close all;

% Add all subfolders (Transmitter, Receiver, etc.) to MATLAB path
% IMPORTANT: Make sure that MATLAB "Current Folder" is the 'CódigosGera' folder
addpath(genpath(pwd));


%%%% 1. SYSTEM PARAMETERS

R = 1/2;           % Target Code Rate
E = 250;           % Maximum physical resources
Q_m = 2;           % Modulation Order (2 = QPSK)

SNR_dB = 8;        % Signal-to-Noise Ratio (dB)

I_max = 100;       % Maximum number of LDPC decoder iterations


fprintf('\n======================================================\n');
fprintf('--- STARTING 5G xGMobile SIMULATION ---\n');


A = input("Enter the message size to be transmitted: "); % Original message size (bits)

msg_original = message_generator(A);

disp("Generated message:")
disp(msg_original);


fprintf('\n[TX] Transmitting packets (Generating all RVs simultaneously)...\n');

[rx_1, rx_2, rx_3, rx_4, BG, Zc, B, c, H] = transmitter(msg_original, R, E, Q_m, SNR_dB);


success = false;

harq_buffer = -1;


for attempt = 1 : 4

    fprintf('\n-> Starting Reception - Attempt %d (HARQ)...\n', attempt);


    if attempt == 1
        received_signal = rx_1; % Attempts decoding with RV=0 first

    elseif attempt == 2
        received_signal = rx_2; % Retrieves stored RV=2

    elseif attempt == 3
        received_signal = rx_3; % Retrieves RV=3

    else
        received_signal = rx_4; % Retrieves RV=1

    end


    fprintf('   [Demodulator] Calculating channel LLR probabilities...\n');

    channel_llrs = ReceiverEntry(received_signal, Q_m, SNR_dB);


    fprintf('   [De-Rate Matching] Reconstructing Circular Buffer...\n');

    harq_buffer = derate_matching(channel_llrs, BG, Zc, Q_m, B, attempt, harq_buffer);


    fprintf('   [LDPC] Running Min-Sum Decoder...\n');

    recovered_LDPC_word = sum_product_decoding(H, harq_buffer, I_max);


    recovered_message = recovered_LDPC_word(1:A);


    errors = sum(msg_original(:) ~= recovered_message(:));


    if errors == 0

        fprintf('\n   [SUCCESS] Message perfectly recovered on attempt %d!\n', attempt);

        success = true;

        %display(recovered_message);

        break;

    else

        fprintf('   [FAILURE] %d incorrect bits were detected.\n', errors);

        if attempt < 4

            fprintf('[!] Triggering automatic HARQ retransmission for attempt %d...\n', attempt + 1);

        end

    end

end


if ~success

    fprintf('Information lost even after HARQ.\n--- TIP: The channel is too noisy. Try increasing the SNR.\n');

else

    fprintf('Communication successfully established.\n');

end