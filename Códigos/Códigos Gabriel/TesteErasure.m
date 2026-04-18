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

%simualação canal 
erasure_prop = 0.5;
tam = length(y_original);
for i = 1 : tam
    if rand <= erasure_prop
        y_original(i) = -1
    end
end

disp('Mensagem Original:');
disp(y_original);

disp('Vetor Recebido com Apagamentos (-1):');
disp(y_original);

% 4. Roda o decodificador
max_iter = 30;
[M1, iter1] = erasureDecoding(y_original, H, max_iter);

disp('Vetor Decodificado pelo MATLAB:');
disp(M1);
