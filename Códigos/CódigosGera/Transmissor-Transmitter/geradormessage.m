%% Função para Gerar a Mensagem Original do Usuário
function msg_original = geradormessage(tamanho_pacote)
    % Gera o pacote de dados real (ex: dados do WhatsApp) com 'tamanho_pacote' bits
    msg_original = randi([0 1], 1, tamanho_pacote);
end