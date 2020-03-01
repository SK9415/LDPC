EbNodB = 6;
R = 1/3; %uncoded BPSK (1bit/symbol)
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*R*EbNo));
%no need foe theoretical BER now
    %BER_th = 0.5*erfc(sqrt(EbNo));
%We don't need N either because now we work on N_block of bits not just N
%number of bits
    % N = 1000;
k = 1; %number of msg bits
n = 3; %number of code word bits

Nerrs = 0; % number of bits of msg per block
N_block = 10000; %we introduced N_block because we need to transmit a large number of bits her (N). 
               %But matlab won't work properly for that BER and N
               %Instead, create only N = 1000 or 100 vectors but loop them
               %it for 1000 or more times. This may take longer because
               %loops are slower in Matlab but at least they will give you
               %desired BER. 
for i = 1:N_block
    msg = randi([0 1],1,k); %generate random k bit msg now
    %enoding will be done here
    cword = [msg msg msg]; % repition of msg itself, n= 3 repition code
    s = 1- 2*cword;
    r = s + sigma * randn(1,n); % AWGN channel
    
    %decd\oding will be done here
    %HARD DECISION
    %threshold at 0. check for each value of array r is < 0, put logical
    %value of that decision in msg_cap array
    % eg: r = [-0.003 0.545 1.5376 -1.463]
    % r<0 = [(-0.003<0) (0.545<0) (1.5376,0) (-1.463<0)]
    % simply put, -0.003 is less that 0, that means the recieved BPSK bit
    % is -1, so actual sigal bit is 1 & vice-versa. So I compared directly
    % => [1 0 0 1]
    b = (r<0);
    if sum(b)>1
        msg_cap1 = 1;
    else
        msg_cap1 = 0;
    end
    
    %SOFT DECISION
    % we know that r is the recieved signal(BPSK with AWGN). For soft decision, we will
    % calculate the Euclidion distance. that means
    % If sq(|[r] - [+1 +1 +1]|)<sq([r]- [-1 -1 -1]| => msg = 0 else msg =1
    %expand this equation, & u will get 
    %if [r] > 0 => msg = 0 else msg = 1
    % note: [+1 +1 +1] is symbol vector for [0 0 0]
    if sum(r)> 0
        msg_cap2 = 0;
    else
        msg_cap2 = 1;
    end
    
    Nerrs = Nerrs + sum(msg ~= msg_cap1); %checking for decision
                                          % msg_cap1 for hard decision
                                          %msg_cap2 for soft decision
end
BER_sim = Nerrs/k/N_block;

disp([EbNodB BER_sim Nerrs k*N_block]);

