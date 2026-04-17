function igual = Comparacao_BG(bg, set, Z) %Compara o BG gerado com o do banco de dados
    BG = Gerador_BG('Base_Graph_2.csv', set, Z);
    nome = sprintf("matlab_code & Base_matrices/base_matrices/NR_%d_%d_%d.txt", bg, set, Z);
    BG2 = readmatrix(nome);
    igual = isequal(BG, BG2);