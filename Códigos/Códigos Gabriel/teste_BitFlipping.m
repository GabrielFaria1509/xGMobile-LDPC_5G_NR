% =========================================================================
% Script de Teste - Bit-Flipping Decoding (Baseado na Apostila)
% =========================================================================
clc; clear;

% 1. Matriz de Paridade H (Exemplo 1.12)
% 1. Parâmetros do 5G
Zc = input('Digite o valor de Zc para a matriz: ');  
% 1. Gera a matriz H com o Base Graph
%é escolhido o set index com base no lifting desejado
Lifting_po_index = readmatrix("Códigos Gabriel\set.csv");

linha_Zc = find(Lifting_po_index(:,1) == Zc);

if isempty(linha_Zc)
    error("Zc inválido! Esse valor não existe na tabela da norma 3GPP.")
end

set_index = Lifting_po_index(linha_Zc,2);
opcao_bg = input("Digite o BG base : ");
% 2. Gera a matriz e faz o lifting
disp('Gerando Matriz do 5G...');
 if opcao_bg == 1
      BG = GeradorBG("Códigos\Códigos Gabriel\BG1.csv", set_index, Zc,opcao_bg);
  elseif opcao_bg == 2
      BG = GeradorBG("Códigos\Códigos Gabriel\BG2.csv", set_index, Zc,opcao_bg);

  else
    error('Opção de BG inválida! O script será encerrado.');

  end
      
H = BaseGraphLifting(BG, Zc);
disp('Matriz H gerada com sucesso!');

spy(H);

%%Gero matriz G
G = GeradorG(H);

%Gero a mensagem
tamanho_pacote = input("Qual tamanho da mensagem ? ");
m = geradormessage(tamanho_pacote);


%Codifico a palavra
palavra_codigo = GeradorPalavraCodigo(m,G);

disp(palavra_codigo);

max_iter = 60; % Limite de segurança

%% Teste: O Cenário de Sucesso (Exemplo 2.3)
disp('======================================================');
disp(' TESTE - Correção por Bit-Flipping');
disp('======================================================');

%Descubro o núemro de colunas de m da matriz H gerada
m = width(H);

% Vetor aleatório recebido
y = geradormessage(m);

%Exibir mensagem antes de sofrer ruído
disp("Mensagem original sem ruído")
display(y);

%Simulação de canal com ruído
% Adicionando ruído ao vetor recebido
noise_level = 0.05; 

%Crio um vetor de 1 linha e colunas m,gera aleatórios entre 0 e 1(rand)
% Onde for menor que 0.1, ele marca como 1 (erro), caso contrário 0 (ok).
mascara_erros = rand(1,m) < noise_level;

disp("Máscara de erros");
disp(double(mascara_erros));


y_ruidoso = double(xor(y,mascara_erros));

% Exibir o vetor ruidoso
disp('Vetor Ruidoso:');
disp(y_ruidoso);


% Chamando a função que criamos
[M, iter,success] = BitFlipping(y_ruidoso, H, max_iter);

fprintf('Iterações necessárias para convergência: %d\n', iter);
disp('Vetor Recebido com Erro:');
disp(y_ruidoso);
disp('Vetor Decodificado pelo MATLAB:');
disp(M);

if success
    disp("Sucesso palavra-código válida");
else
    disp("Falha palavra-código inválida");
end


