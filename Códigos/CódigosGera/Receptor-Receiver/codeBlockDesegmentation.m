function [msg_crc_recovered, crc_cb_pass] = codeBlockDesegmentation(decoded_blocks, C, B)
    if C > 1
        L = 24;
    else
        L = 0;
    end
    
    complete_message = [];
    crc_cb_pass = true; % Flag de integridade do pacote de blocos
    
    for i = 1 : C
        block = decoded_blocks{i};
        
        % Força o bloco a ser um vetor linha para evitar quebras de dimensão
        block = block(:).'; 
        usable_size = length(block) - L;
        
        % 1. Blindagem de tamanho: Verifica se o bloco não foi mutilado no processo
        if usable_size <= 0
            fprintf('[Dessegmentação] ERRO CRÍTICO: Bloco %d tem apenas %d bits (esperado > %d).\n', i, length(block), L);
            crc_cb_pass = false;
            continue; 
        end
        
        % 2. Extrai a parte útil (informação pura + fillers)
        useful_block = block(1 : usable_size);
        
        if L > 0
            % Extrai os 24 bits de CRC recebidos no final do bloco
            received_crc = block(usable_size + 1 : end);
            
            % Recalcula o CRC localmente (CRC 24B para blocos)
            calculated_crc = crc_generator(useful_block, "24B");
            
            % Compara garantindo que ambos são vetores linha
            if isequal(received_crc(:).', calculated_crc(:).')
                fprintf('[Dessegmentação] Bloco %d/%d: CRC Válido! ✅\n', i, C);
            else
                fprintf('[Dessegmentação] ALERTA: Bloco %d/%d falhou no CRC! ❌\n', i, C);
                crc_cb_pass = false;
            end
        end
        % =================================================================
        
        % 3. Concatena os blocos limpos
        complete_message = [complete_message, useful_block];
    end
    
    % 4. Blindagem do Truncamento de Filler Bits
    if length(complete_message) >= B
        % Corta os filler bits excedentes para voltar ao tamanho B (Msg + Transporte)
        msg_crc_recovered = complete_message(1:B);
    else
        fprintf('[Dessegmentação] ERRO: Mensagem concatenada (%d bits) é menor que B (%d bits). Preenchendo com zeros.\n', length(complete_message), B);
        % Preenche a diferença com zeros para o CRC-24A principal avaliar a falha sem travar
        padding = zeros(1, B - length(complete_message));
        msg_crc_recovered = [complete_message, padding];
    end
end