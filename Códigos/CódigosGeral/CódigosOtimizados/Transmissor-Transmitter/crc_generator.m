function CRC = crc_generator(bit_sequence, crc_type)

    bit_sequence = bit_sequence(:).';

    A = length(bit_sequence);

    if nargin < 2
        if A > 3824
            crc_type = "24A";
        else
            crc_type = "16";
        end
    end

    switch crc_type

        case "24A"      % Transport Block CRC
            L = 24;
            g = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];

        case "24B"      % Code Block CRC
            L = 24;
            g = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1];

        case "16"       % Transport Block CRC for short blocks
            L = 16;
            g = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];

        otherwise
            error('Invalid CRC type. Use: "24A", "24B" or "16".');

    end

    dividend = [bit_sequence, zeros(1, L)];

    for i = 1:A
        if dividend(i) == 1
            dividend(i:i+L) = mod(dividend(i:i+L) + g, 2);
        end
    end

    CRC = dividend(end-L+1:end);

end