function c = H_matrix_codeword_generator(message, H, Zc, BGn)

    if BGn == 1
        Kb = 22;
    else
        Kb = 10;
    end

    core = H(1:4*Zc, Kb*Zc+1:(Kb+4)*Zc);
    topo = H(1:4*Zc, 1:Kb*Zc);

    bits_sistematicos = gerador_bits_sistematicos(message, core, topo, Zc, BGn);

    csis=[message bits_sistematicos];
    %csis=message;

    BlocoSis=H(4*Zc+1:end,1:(Kb+4)*Zc);

    c = [csis mod(csis*BlocoSis',2)];