% =========================================================================
% Script de Teste - Erasure Decoding (Canal de Apagamento)
% =========================================================================
clc; clear;

% 1. Gera a matriz H com o Base Graph
Zc = input('Digite o valor de Zc para a matriz: ');  
set_index = input('Digite o set index : ');
opcao_bg = input('Digite o BG base (1 para BG1, 2 para BG2): ');

% 2. Gera a matriz e faz o lifting
disp('Gerando Matriz do 5G...');
if opcao_bg == 1
    BG = GeradorBG("Códigos\Códigos Gabriel\BG1.csv", set_index, Zc, opcao_bg);
elseif opcao_bg == 2
    BG = GeradorBG("Códigos\Códigos José\Base_Graph_2.csv", set_index, Zc, opcao_bg);
else
    error('Opção de BG inválida! O script será encerrado.');
end

H = BaseGraphLifting(BG, Zc);
disp('Matriz H gerada com sucesso!');

% Descubro o número de colunas m da matriz H gerada
m = width(H);

% 3. Gera a mensagem (Usando zeros provisoriamente como combinado)
y_original = geradormessage(m); 

% Simulação canal (Canal de Apagamento)
erasure_prop = 0.5; % 50% de apagamento (bem agressivo para testes)
tam = length(y_original);

% Cria uma cópia para o canal estragar, preservando a original
y_apagado = y_original; 

for i = 1 : tam
    if rand <= erasure_prop
        y_apagado(i) = -1; % <- Ponto e vírgula adicionado aqui!
    end
end

disp('Mensagem Original:');
disp(y_original); 

disp('Vetor Recebido com Apagamentos (-1):');
disp(y_apagado);

% 4. Roda o decodificador
max_iter = 30;

% Adicionado o 'success' na chamada da função
[M1, iter1, success] = erasureDecoding(y_apagado, H, max_iter);

disp('Vetor Decodificado pelo MATLAB:');
disp(M1(1:min(20, m)));

if success
    disp("-> Sucesso: palavra-código válida e apagamentos corrigidos!");
else
    disp("-> Falha: palavra-código inválida (Muitos apagamentos para recuperar).");
end