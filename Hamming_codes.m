EbNodB = 5; % ebno in db. we need this as we need to get value of sigma for noise
R = 4/7; %Hamming code for 4 bit coded into 7 bits BPSK (1bit/symbol)
EbNo = 10^(EbNodB/10); %get linear eb/n0 

%sigma is the standard deviation for AWGN noise
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
 
%dec2bin(0:15,4) will return 16 string of 0000, 0001, 0010,.... til 1111
%Since it is a string, we need to convert it into array of bits
% for e.g., string '0010' needs to be converted into [0 0 1 0] so that we
% can multiply it with G matrix. That's why we need to perform 'string' -
% '0' or 'string' - 48
code_words = mod((dec2bin(0:15,4)- '0')*G,2);

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
    
    % Modulo 2 addition or XOR of bits as parity.
    cword = [msg mod(msg(1) + msg(2) + msg(3),2)...
                 mod(msg(2) + msg(3) + msg(4),2)...
                 mod(msg(1) + msg(2) + msg(4),2)]; 
    
    %s is the modulated signal of BPSK format
    % 0 = +1, 1 = -1
    % suppose c word = 1001,then s = [1 - 2*1 1-2*0 1-2*0 1-2*1] = [-1 1 1 -1]
    s = 1 - 2*cword;
    
    % r is the received signal after going through AWGN channel 
    % randn - Gaussian distributed random n numbers. randn generates for
    % unit variance so multiplied it by sigma to get variance of sigma
    % square.
    r = s + sigma * randn(1,n); 
                                
    
    %decoding will be done here
    %HARD DECISION
    %threshold at 0. check for each value of array r is < 0, put logical
    %value of that decision in msg_cap array
    % eg: r = [-0.003 0.545 1.5376 -1.463]
    % r<0 = [(-0.003<0) (0.545<0) (1.5376,0) (-1.463<0)]
    % simply put, -0.003 is less that 0, that means the recieved BPSK bit
    % is -1, so actual sigal bit is 1 & vice-versa. So I compared directly
    % => [1 0 0 1]
    b = (r<0);
    dist = mod(repmat(b,16,1)+code_words,2); % repmat- repeat matrix will create 16 times the 'b'
                                      % vector and it will XOR with modulo
                                      % 2 with every possible codeword generated
                                      % above
    % calculate the weights
    dist_array = dist * ones(7,1);  
    [minD1, pos] = min(dist_array);
    %Get the first 4 bits on the position pos
    msg_cap1 = code_words(pos,1:4);
    
    %SOFT DECISION
    corr = (1-2*code_words)*r';
    [minD2, pos] = max(corr);
    %Get the first 4 bits from the position pos from arrayy code_words
    msg_cap2 = code_words(pos,1:4); 
    
    %check if msg bits are equal to msg_cap bits.
    % This will give number of errors in that iteration. 
    Nerrs = sum(msg ~= msg_cap2);
    %checking for decision
        % (msg_cap1 for hard decision)
        % (msg_cap2 for soft decision)
    
    
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

