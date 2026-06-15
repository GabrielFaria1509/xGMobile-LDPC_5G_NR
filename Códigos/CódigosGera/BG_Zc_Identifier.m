function [BG,Zc_selected] = BG_Zc_Identifier(demodulated_signal,CodeRate,K)

%%Demodulated_signal = Received message by the receptor
%%K = Lenght of the received message including CRC verification bits
%%Kb = Maximum number of columns in the matrix that contain useful information.
%%Zc_min = Minimum Zc possible 

message_size = length(demodulated_signal);

if message_size <= 292 || (message_size <= 3824 && CodeRate <=0.67) || CodeRate <=0.25
    BG = 2;
else
    BG = 1;
end

if BG == 2
    if message_size <= 192
        Kb = 6;
    elseif message_size > 192 && message_size <=560
        Kb = 8;
    elseif message_size > 560 && message_size <=640
        Kb = 9;
    elseif message_size > 640
        Kb = 10;
    end
else
    Kb = 22;
end

Zc_min = K/Kb;

database = readmatrix("set.csv");

%%Readinh ther first column of the file to define the minimum Zc
Zc = database(:, 1); % Extract the first column from the database

%%Scaning the list of Zc and extracting the first value that is greater
%%than or equal to Zc_min
valid_Zc_indices = find(Zc_list>=Zc_min);

if ~isempty(valid_Zc_indices)
    Zc_selected = Zc(valid_Zc_indices(1)); % Select the first valid Zc value
else
    error("No supported Zc value matches the current block size (K).")
end













