function crc_simulado = simulador_crc(A)
    %simula um CRC aleatório com o tamanho correto de bits
    if A > 3824
        crc_simulado = randi([0 1], 1, 24);
    else
        crc_simulado = randi([0 1], 1, 16);
    end