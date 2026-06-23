function CRC = crc_generator(message)
    
    A = length(message);

    if A > 3824
        L = 24;
        g = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];

    else
        L = 16;
        g = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    end

    temp_message = [message,zeros(1,L)];

    for i = 1 : A
        if temp_message(i) == 1
            temp_message(i:i+L) = mod(temp_message(i:i+L) + g,2);
        end
    end

    CRC = temp_message(end - L + 1 : end);
end




    
    