function BG = baseGraph_generator(BG_number, Zc)
    %% ====================================================================
    % FUNCTION: baseGraph_generator
    % DESCRIPTION: Generates the selected LDPC Base Graph by applying the
    %              modulo operation to the shift coefficients according to
    %              the selected lifting size (Zc).
    % REFERENCE: 3GPP TS 38.212
    %
    % INPUTS:
    %   BG_number - Selected Base Graph (1 or 2)
    %   Zc        - Lifting size
    %
    % OUTPUT:
    %   BG        - Lifted Base Graph
    %% ====================================================================

    % Table containing the lifting set index for each valid Zc
    table = readtable('set.csv');
    lifting_set = table(table.lifting == Zc, :);

    if isempty(lifting_set)
        error("Non-standard lifting size");
    end

    % i_ls corresponds to the lifting set index defined in TS 38.212
    i_ls = lifting_set{1,2};

    % Load the selected Base Graph
    if BG_number == 1
        base = readtable('BG1.csv');
        BG = ones(46, 68) * -1;
    else
        base = readtable('BG2.csv');
        BG = ones(42, 52) * -1;
    end

    for i = 1:height(base)

        % Row and column indices of the Base Graph
        row_idx = base{i,1};
        col_idx = base{i,2};

        % V_ij is the shift coefficient defined in TS 38.212
        V_ij = base{i,sprintf('s%d', i_ls)};
        shift_value = mod(V_ij, Zc);

        BG(row_idx+1, col_idx+1) = shift_value;
    end
end