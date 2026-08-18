function [BG, Zc_selected] = BG_Zc_Identifier(A, CodeRate, K)

    %% K = Length of the input message including CRC verification bits
    %% Kb = Maximum number of columns in the Base Graph containing useful information
    %% Zc_min = Minimum lifting size required
    %% A = Original Transport Block Size (TBS)


    % Base Graph selection according to 5G NR LDPC rules

    if A <= 292 || (A <= 3824 && CodeRate <= 0.67) || CodeRate <= 0.25

        BG = 2;

    else

        BG = 1;

    end


    if nargin < 3

        Zc_selected = [];

        return;

    end


    % Determination of Kb according to the selected Base Graph

    if BG == 2

        if A <= 192

            Kb = 6;

        elseif A > 192 && A <= 560

            Kb = 8;

        elseif A > 560 && A <= 640

            Kb = 9;

        elseif A > 640

            Kb = 10;

        end

    else

        Kb = 22;

    end


    % Minimum lifting size calculation

    Zc_min = K / Kb;


    database = readmatrix("set.csv");


    %% Reading the first column from the database to define possible Zc values

    Zc = database(:,1);


    %% Searching for the first supported Zc value greater than or equal to Zc_min

    valid_Zc_indices = find(Zc >= Zc_min);


    if ~isempty(valid_Zc_indices)

        Zc_selected = Zc(valid_Zc_indices(1)); % Select the first valid Zc value

    else

        error("No supported Zc value matches the current block size (K).");

    end

end