function [palavra_codigo] = GeradorPalavraCodigo(mensagem,G)
%verificar se o tamanho da mensagem bate com a matriz G
[k_G,~] = size(G);

if length(mensagem) ~= k_G
    error('Erro: O tamanho da mensagem não bate com a Matriz Geradora!');
end

% 2. Codificação (Multiplicação em GF(2))
% Multiplica a mensagem original por G e aplica o módulo 2

palavra_codigo = mod(mensagem*G,2);

end