function [msg_crc_recovered, crc_cb_pass] = codeBlockDesegmentation(decoded_blocks, C, B)

    if C > 1

        L = 24;

    else

        L = 0;

    end


    complete_message = [];

    crc_cb_pass = true; % Code block integrity flag


    for i = 1 : C

        block = decoded_blocks{i};


        % Forces the block to be a row vector to avoid dimension mismatch

        block = block(:).';


        usable_size = length(block) - L;



        % 1. Size protection: Checks if the block was corrupted during processing

        if usable_size <= 0

            fprintf('[Desegmentation] CRITICAL ERROR: Block %d has only %d bits (expected > %d).\n', ...
                i, length(block), L);


            crc_cb_pass = false;

            continue;

        end



        % 2. Extracts the useful part (information bits + filler bits)

        useful_block = block(1 : usable_size);



        if L > 0


            % Extracts the 24 received CRC bits at the end of the block

            received_crc = block(usable_size + 1 : end);



            % Locally recalculates the CRC (CRC-24B for code blocks)

            calculated_crc = crc_generator(useful_block, "24B");



            % Compares both vectors as row vectors

            if isequal(received_crc(:).', calculated_crc(:).')

                fprintf('[Desegmentation] Block %d/%d: Valid CRC! \n', i, C);


            else

                fprintf('[Desegmentation] WARNING: Block %d/%d failed CRC validation! \n', i, C);

                crc_cb_pass = false;

            end

        end



        % 3. Concatenates validated blocks

        complete_message = [complete_message, useful_block];

    end



    % 4. Filler bits truncation protection

    if length(complete_message) >= B


        % Removes excess filler bits to recover the original size B
        % (Transport message + CRC)

        msg_crc_recovered = complete_message(1:B);



    else


        fprintf('[Desegmentation] ERROR: Concatenated message (%d bits) is smaller than B (%d bits). Padding with zeros.\n', ...
            length(complete_message), B);


        % Pads missing bits with zeros to allow the main CRC-24A
        % verification to detect failure without stopping execution

        padding = zeros(1, B - length(complete_message));


        msg_crc_recovered = [complete_message, padding];


    end

end