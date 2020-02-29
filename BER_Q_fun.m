EbNodB = 4;
R = 1; %uncoded BPSK (1bit/symbol)
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/2*R*(EbNo));

BER_th = 0.5*erfc(sqrt(EbNo));

disp([EbNodB BER_th]);
