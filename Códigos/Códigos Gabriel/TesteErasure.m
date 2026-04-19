clc; clear;

% 1. Gera a matriz H com o Base Graph
Zc = 3;
set_index  = 0;
disp('Gerando Matriz do 5G...');
BG = GeradorBG1("Códigos\Códigos Gabriel\BG1.csv", set_index, Zc);
H = BaseGraphLifting(matriz_base, Zc);
disp('Matriz H gerada com sucesso!');

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
