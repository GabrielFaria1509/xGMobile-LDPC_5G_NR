function BG_number = Base_Graph_selector(A, R)
    %% ====================================================================
    % FUNCTION: Base_Graph_selector
    % DESCRIPTION: Selects the LDPC Base Graph (BG1 or BG2) according to
    %              the transport block size and the target code rate.
    % REFERENCE: 3GPP TS 38.212
    %
    % INPUTS:
    %   A - Transport block size (without TB CRC), in bits
    %   R - Target code rate
    %
    % OUTPUT:
    %   BG_number - Selected Base Graph (1 or 2)
    %% ====================================================================

    % Select the Base Graph according to TS 38.212
    if A <= 292
        BG_number = 2;
    elseif A <= 3824 && R <= 0.67      % 0.67 ≈ 2/3
        BG_number = 2;
    elseif R <= 0.25
        BG_number = 2;
    else
        BG_number = 1;
    end
end