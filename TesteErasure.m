clc; clear;

% 1. Gera a matriz H com o Base Graph
B = [0 2 -1 1; 
     1 -1 2 0];
Zc = 3;
H = BaseGraphLifting(B,Zc);
%Descubro o núemro de colunas de m da matriz H gerada

m = width(H);

% 2. Gera a mensagem aleatória (sabemos que para esse B e Zc, são 12 bits)
y_original = geradormessage(m);

% 3. Insere os apagamentos (usando -1)
erasure_prob  = 0.4;

%se cumprir a condição elemento recebe 1,caso contrário 0
mascara_apagamentos = rand(1,m) < erasure_prob;

%Onde for 0 troco por -1 para ser o bit apagado
y_apagado = y_original;
y_apagado(mascara_apagamentos) = -1;



disp('Vetor Recebido com Apagamentos (-1):');
disp(y_apagado);


disp('Mensagem Original:');
disp(y_original);

% 4. Roda o decodificador
max_iter = 30;
[M1, iter1,success] = erasureDecoding(y_apagado, H, max_iter);

disp('Vetor Decodificado pelo MATLAB:');
disp(M1);

if success
    disp("Resultado : Sucesso,palavra decodificada é uma palavra-código válida");
else
    disp("RESULTADO: Falha(Stopping Set ou Palavra Inválida).");
end