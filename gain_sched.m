function [k_p, k_i, k_d, min_write] = gain_sched(h_bola)
    if h_bola <= 30
        min_write = 3.5; %minima tensão p/ flutuar
        k_p = 8.; 
        k_i = 4.8;
        k_d = 0.4;
    elseif h_bola > 30 && h_bola <= 60
        min_write = 3.35; %minima tensão p/ flutuar
        k_p = 1.3;
        k_i = 0.6;
        k_d = 0.04;
    else
        min_write = 3.35; %minima tensão p/ flutuar
        k_p = 1.7;
        k_i = 0.6;
        k_d = 0.06;
    end
end

