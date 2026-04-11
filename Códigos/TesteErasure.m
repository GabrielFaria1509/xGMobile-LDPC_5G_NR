clc; clear;

% 1. Gera a matriz H com o Base Graph
B = [0 2 -1 1; 
     1 -1 2 0];
Zc = 3;
s = 5;
H = BaseGraphLifting(B, Zc, s);
%Descubro o núemro de colunas de m da matriz H gerada
m = width(H);

% 2. Gera a mensagem aleatória (sabemos que para esse B e Zc, são 12 bits)
y_original = geradormessage(m);

% 3. Insere os apagamentos (usando -1)
num_apagamentos = 3;

posicoes_apagadas = randperm(width(y_original),num_apagamentos)

disp('Vetor Recebido com Apagamentos (-1):');
y1 = y_original;
y1(posicoes_apagadas) = -1;

disp('Mensagem Original:');
disp(y_original);

disp('Vetor Recebido com Apagamentos (-1):');
disp(y1);

% 4. Roda o decodificador
max_iter = 30;
[M1, iter1] = erasureDecoding(y1, H, max_iter);

disp('Vetor Decodificado pelo MATLAB:');
disp(M1);
