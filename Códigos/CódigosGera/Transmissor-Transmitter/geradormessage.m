%% Função para Gerar a Mensagem Original do Usuário
function original_message = message_generator(package_size)
    % Gera o pacote de dados real (ex: dados do WhatsApp) com 'tamanho_pacote' bits
    original_message = randi([0 1], 1, package_size);
end