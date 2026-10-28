function c = ldpc_encode_nr_process(s, dados)

    % Organiza a mensagem
    s = s(:);

    % Recupera os dados pre-processados
    A = dados.A;
    B = dados.B;
    Dinv_C = dados.Dinv_C;

    % Calcula os primeiros bits de paridade
    p1 = mod(Dinv_C * s, 2);

    % Calcula os bits de paridade restantes
    p2 = mod(A * s + B * p1, 2);

    % Monta a palavra-codigo
    p = [p1; p2];
    c = [s; p]';

end