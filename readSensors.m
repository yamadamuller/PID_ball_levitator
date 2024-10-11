function h_bola = readSensors(ut_probe, h_tubo) 
    h_bola = h_tubo - readDistance(ut_probe)*100 - 3.8; %altura da bola em relação a base
    if h_bola == inf %se chegar mto perto do sensor a leitura é inf 
        h_bola = 0;
    end
end

