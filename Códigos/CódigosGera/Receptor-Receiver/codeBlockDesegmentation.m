function msg_crc_recovered = codeBlockDesegmentation(decoded_blocks, C, B)
    if C > 1
        L = 24;
    else
        L = 0;
    end
    
    complete_message = [];
    
    for i = 1 : C
        block = decoded_blocks{i};
        usable_size = length(block) - L;
        
        % 1. Extrai a parte útil (informação pura + fillers)
        useful_block = block(1 : usable_size);
        
        if L > 0
            % Extrai os 24 bits de CRC recebidos no final do bloco
            received_crc = block(usable_size + 1 : end);
            
            % Recalcula o CRC localmente (CRC 24B para blocos)
            calculated_crc = crc_generator(useful_block, "24B");
            
            % Compara se o CRC calculado é idêntico ao recebido
            if isequal(received_crc, calculated_crc)
                fprintf('[Dessegmentação] Bloco %d/%d: CRC Válido! ✅\n', i, C);
            else
                fprintf('[Dessegmentação] ALERTA: Bloco %d/%d falhou no CRC! ❌ (Possível erro de canal)\n', i, C);
            end
        end
        % =================================================================
        
        % 2. Concatena os blocos limpos
        complete_message = [complete_message, useful_block];
    end
    
    % 3. Corta os filler bits excedentes para voltar ao tamanho B (Msg + Transporte)
    msg_crc_recovered = complete_message(1:B);
end