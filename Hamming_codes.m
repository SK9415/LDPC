EbNodB = 4;
R = 4/7; %Hamming code for 4 bit coded into 7 bits BPSK (1bit/symbol)
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*R*EbNo));
%no need foe theoretical BER now
    %BER_th = 0.5*erfc(sqrt(EbNo));
%We don't need N either because now we work on N_block of bits not just N
%number of bits
    % N = 1000;
k = 4; %number of msg bits
n = 7; %number of code word bits

G = [1 0 0 0 1 0 1;
     0 1 0 0 1 1 1;
     0 0 1 0 1 1 0;
     0 0 0 1 0 1 1;];
 
code_words = mod((dec2bin(0:15,4)- '0')*G,2);

% 
% 
% code_words1 = [0     0     0     0     0     0     0;
%               0     0     0     1     0     1     1;
%               0     0     1     0     1     1     0;
%               0     0     1     1     1     0     1;
%               0     1     0     0     1     1     1;
%               0     1     0     1     1     0     0;
%               0     1     1     0     0     0     1;
%               0     1     1     1     0     1     0;
%               1     0     0     0     1     0     1;
%               1     0     0     1     1     1     0;
%               1     0     1     0     0     1     1;
%               1     0     1     1     0     0     0;
%               1     1     0     0     0     1     0;
%               1     1     0     1     0     0     1;
%               1     1     1     0     1     0     0;
%               1     1     1     1     1     1     1];
 
Nbiterrs = 0; % number of bits of msg per block
Nblockerrs =0;

N_block = 1000; %we introduced N_block because we need to transmit a large number of bits her (N). 
               %But matlab won't work properly for that BER and N
               %Instead, create only N = 1000 or 100 vectors but loop them
               %it for 1000 or more times. This may take longer because
               %loops are slower in Matlab but at least they will give you
               %desired BER. 
for i = 1:N_block
    msg = randi([0 1],1,k); %generate random k bit msg now
    %enoding will be done here
    cword = [msg mod(msg(1) + msg(2) + msg(3),2)...
                 mod(msg(2) + msg(3) + msg(4),2)...
                 mod(msg(1) + msg(2) + msg(4),2)]; % Modulo 2 addition or XOR of bits as parity.
    s = 1- 2*cword;
    r = s + sigma * randn(1,n); % AWGN channel
    
    %decoding will be done here
    %hard decision
    b = (r<0);
    dist = mod(repmat(b,16,1)+code_words,2); % repmat- repeat matrix will create 16 times the 'b'
                                      % vector and it will XOR with modulo
                                      % 2 with every possible codeword generated
                                      % above
    dist_array = dist * ones(7,1); % calculate the weights 
    [minD1, pos] = min(dist_array);
    msg_cap1 = code_words(pos,1:4);
    
    %soft decision
    
    corr = (1-2*code_words)*r';
    [minD2, pos] = max(corr);
    msg_cap2 = code_words(pos,1:4);
    
    %check if msg bits are equal to msg_cap bits.
    % This will give number of errors in that iteration. 
    Nerrs = sum(msg ~= msg_cap2);         %checking for decision
                                          % msg_cap1 for hard decision
                                          %msg_cap2 for soft decision
    %calculate block errors
    %If there was an error in that block, add it to total number of bit
    %errors - Nbiterrs. Also, add +1 to Nblockerrs to indicate that error
    %was found in this block and keep adding to it to get total number of
    %block errors
    
    if(Nerrs>0)                             
       Nbiterrs = Nbiterrs + Nerrs;
       Nblockerrs = Nblockerrs + 1; 
    end
    
end

%Bit error rate
BER_sim = Nbiterrs/k/N_block;

%Frame or block error rate
FER_sim = Nblockerrs/N_block;
disp([EbNodB FER_sim BER_sim Nblockerrs Nbiterrs N_block]);

