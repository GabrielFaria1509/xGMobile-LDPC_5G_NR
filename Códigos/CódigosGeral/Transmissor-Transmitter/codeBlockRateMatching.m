function [rate_matched_block_RV1, rate_matched_block_RV2, ...
          rate_matched_block_RV3, rate_matched_block_RV4] = ...
          codeBlockRateMatching(encoded_code_blocks, C, E, BG_number, Zc, Q_m)

    % Initialize the output sequences
    rate_matched_block_RV1 = [];
    rate_matched_block_RV2 = [];
    rate_matched_block_RV3 = [];
    rate_matched_block_RV4 = [];

    %% Symbol-based allocation (guarantees multiples of Q_m)
    total_symbols = floor(E / Q_m);
    symbols_per_CB = floor(total_symbols / C);
    remaining_symbols = mod(total_symbols, C);

    E_base = symbols_per_CB * Q_m;

    for i = 1:C

        codeword = encoded_code_blocks{i};

        % The first 'remaining_symbols' Code Blocks receive one extra symbol
        if (i - 1) < remaining_symbols
            E_r = E_base + Q_m;
        else
            E_r = E_base;
        end

        % Rate Matching for each Redundancy Version (RV)
        rate_matched_CB_RV1 = RateMatching(codeword, BG_number, Zc, E_r, Q_m, 1);
        rate_matched_CB_RV2 = RateMatching(codeword, BG_number, Zc, E_r, Q_m, 2);
        rate_matched_CB_RV3 = RateMatching(codeword, BG_number, Zc, E_r, Q_m, 3);
        rate_matched_CB_RV4 = RateMatching(codeword, BG_number, Zc, E_r, Q_m, 4);

        rate_matched_block_RV1 = [rate_matched_block_RV1, rate_matched_CB_RV1];
        rate_matched_block_RV2 = [rate_matched_block_RV2, rate_matched_CB_RV2];
        rate_matched_block_RV3 = [rate_matched_block_RV3, rate_matched_CB_RV3];
        rate_matched_block_RV4 = [rate_matched_block_RV4, rate_matched_CB_RV4];

    end

end