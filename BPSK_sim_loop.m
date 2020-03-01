EbNodB = 6;
R = 1; %uncoded BPSK (1bit/symbol)
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*R*EbNo));

BER_th = 0.5*erfc(sqrt(EbNo));
Nerrs = 0;
N = 1000; % number of bits of msg per block
N_block = 100000; %we introduced N_block because we need to transmit a large number of bits her (N). 
               %But matlab won't work properly for that BER and N
               %Instead, create only N = 1000 or 100 vectors but loop them
               %it for 1000 or more times. This may take longer because
               %loops are slower in Matlab but at least they will give you
               %desired BER. 
for i = 1:N_block
    msg = randi([0 1],1,N); %generate random msg
    %enoding will be done here
    s = 1- 2*msg; %BPSK signal 
    r = s + sigma * randn(1,N); % AWGN channel
    %decd\oding will be done here
    %threshold at 0. check for each value of array r is < 0, put logical
    %value of that decision in msg_cap array
    % eg: r = [-0.003 0.545 1.5376 -1.463]
    % r<0 = [(-0.003<0) (0.545<0) (1.5376,0) (-1.463<0)]
    % => [1 0 0 1]
    msg_cap = (r<0); 

    Nerrs = Nerrs + sum(msg ~= msg_cap);
end
BER_sim = Nerrs/N/N_block;

disp([EbNodB BER_th BER_sim Nerrs N*N_block]);

