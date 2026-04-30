function igual = Comparacao_BG(bg, set, Z) %Compara o BG gerado com o do banco de dados
    BG = Gerador_BG(bg, Z);
    nome = sprintf("matlab_code & Base_matrices/base_matrices/NR_%d_%d_%d.txt", bg, set, Z);
    BG2 = readmatrix(nome);
    igual = isequal(BG, BG2);
    [l, c] = find(BG~=BG2);
    display([l,c])