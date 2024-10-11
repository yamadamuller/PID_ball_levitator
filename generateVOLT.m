function elapsed_time = generateVOLT(volt, ino)
    elapsed_time = 0;
    tic
    writePWMVoltage(ino, 'D9', round(volt,3)); %tensão média do PWM == volt
    elapsed_time = elapsed_time + toc; %registra tempo que leva para ação
end

