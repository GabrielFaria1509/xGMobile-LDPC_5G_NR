clc;
set_index = 0
Z = 2

BG = Gerador_BG('Base_Graph_2.csv', set_index, Z)

H = Gerador_H(BG, Z)

c = Rand_c(H, 2500)

y = Canal_Erasure(0.1, c)

M = Erasure_Decoding(H, y, 100)

if M == c
    disp('Decodificação bem sucedida');
else
    disp('Decodificação mal sucedida');
end

sucesso = 0;
falha = 0;
for i = 1:1
    %y2 = Canal_Erasure(0.1, c);
    %[M2, c, y2] = Erasure_Decoding(H, y2, 10);

    if M2 == c
        sucesso = sucesso + 1;
    else
        falha = falha + 1;
    end
end
sucesso
falha
taxa = (sucesso / (sucesso + falha))*100