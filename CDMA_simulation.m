clc ;
close all ;
clear all ;

num_bits = 1000 ;
num_users = 4 ;
SNR_db = 0:5:20 ;

bit_sequence = randi([0 1] , num_bits , num_users);

code_length = 8 ;
codes = hadamard(code_length);
user_codes = codes(1 : num_users , : );

spread_code = zeros(num_bits , code_length , num_users);
for u = 1:num_users
    bits = 2*bit_sequence(: , u) - 1 ;
    spread_code(:, :, u) = bits * user_codes(u, :);
end

tx_signal = sum(spread_code , 3);
tx_signal = tx_signal(:)' ;

ber = zeros(length(SNR_db) , num_users);
x = length(SNR_db) ;

for k = 1 : x 
    noise_signal = awgn(tx_signal , SNR_db(k) , 'measured');

    Rx_signal = zeros( num_bits , num_users);
    for u = 1 : num_users
        code = user_codes(u , :);
        for i = 1:num_bits 
            Rx_segment = noise_signal((i-1)*code_length+1 : i*code_length);
            Rx_bits = sum(Rx_segment .* code);
            Rx_signal(i , u) = Rx_bits > 0 ;
        end
    end
    
    for u = 1 : num_users
        ber(k , u) = sum(Rx_signal(: , u) ~= bit_sequence(: , u)) / num_bits ;
    end
end

figure ;
semilogy(SNR_db , ber);
xlabel('SNR(db)');
ylabel('Bit Error Rate');
legend('User 1','User 2','User 3','user 4' , Location = 'best');
title('SNR(db) vs BER for multiple users');
grid on ;

