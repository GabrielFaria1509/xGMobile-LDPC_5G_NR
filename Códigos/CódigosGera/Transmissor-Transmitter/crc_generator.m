function CRC = crc_generator(message,crc_option)

     A = length(message);


    if nargin < 2
        if A > 3824
            crc_option = "24A";
        else
            crc_option = "16";
        end
    end

   switch crc_option
       case "24A"  %For big messages but not with code block segmentation
            L = 24;
            g = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
       case "24B"  %%For code blocks
            L = 24;
            g = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1];
       case "16" %for short messages
            L = 16;
            g = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
        otherwise
            error('Tipo de CRC inválido. Use: "24A", "24B" ou "16".');
    end
    
    temp_message = [message,zeros(1,L)];

    for i = 1 : A
        if temp_message(i) == 1
            temp_message(i:i+L) = mod(temp_message(i:i+L) + g,2);
        end
    end

    CRC = temp_message(end - L + 1 : end);
end




    
    