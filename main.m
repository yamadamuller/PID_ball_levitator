clear all;
clc;
clf;

%hardware info struct
ino.hw = arduino('COM3', 'UNO','Libraries','Ultrasonic');
ino.ut = ultrasonic(ino.hw, 'D7', 'D6');

%loop config
h_tubo = 100; %altura do tubo de plástico
run_iter = intmax; %número de iterações
period(1) = 0; %periodo para controle de plot
h(1) = 0; %vetor das alturas
up(1) = 0; %vetor da ação proporcional
ui(1) = 0; %vetor da ação integral
ud(1) = 0; %vetor da ação derivativa
N = 7; %polo do filtro

%PID
setpoint = 70; %setpoint inicial desejado
max_write = 5; %maxima tensão aceito
u_past = 0; %output passado do PID discreto
u_now = 0; %output atual do PID discreto
err = [0 0]; %vetor de erros passados
Ts = 0.01; %periodo amostragem arbitrário
eaw = 0; %erro limitador AW
end_time = 0; %controle de plot

%Criando objeto de plot
figure(1)
subplot(4,1,1)
h_plot = plot(period, h); % Guarda as informações do plot para atualização 
set(h_plot,'LineWidth', 1);
title('Resposta do Sistema');
ylabel("Altura [cm]");
ylim([0 120]);
ylineObj = yline(setpoint,'red');
legend('Sensor', 'Setpoint', Location='northwest');

subplot(4,1,2)
temp_plot2 = plot(period, up, Color='magenta');
set(temp_plot2,'LineWidth', 1);
title('Ação proporcional');

subplot(4,1,3)
temp_plot3 = plot(period, ui, Color='magenta');
title('Ação integral');
set(temp_plot3,'LineWidth', 1);

subplot(4,1,4)
temp_plot4 = plot(period, ud, Color='magenta');
set(temp_plot4,'LineWidth', 1);
title('Ação derivativa');
xlabel("Tempo decorrido [s]");

for i=2:run_iter
    tic

    %Leitura dos componentes
    h(i) = readSensors(ino.ut, h_tubo); %altura da bola
    period(i) = period(i-1) + toc + end_time; %periodo da função de hw

    %PID discreto
    [Kp, Ki, Kd, min_write] = gain_sched(setpoint); %gain scheduling
    Taw = sqrt((Kp/Ki)*(Kd/Kp)); %Constante de tempo anti-windup
    err_now = setpoint - h(i); %termo de erro
    up(i) = Kp*err_now - Kp*err(1); %ação proporcional
    ui(i) = ui(i-1) + Ki*Ts*err_now + (Ts/Taw)*eaw; %ação integral c/ AW
    %ui(i) = Ki*Ts*err_now; %ação integral
    ud(i) = (Kd/Ts)*err_now - (2*Kd/Ts)*err(1) + (Kd/Ts)*err(2); %ação der.
    %ud(i) = (ud(i-1) + Kd*N*err_now - Kd*N*err(1))/(1 + Ts*N); %filtro no derivatico
    u_now = u_past + up(i) + ui(i) + ud(i); %saída do PID

    %Plots
    set(h_plot, 'XData', period, 'YData', h); 
    set(temp_plot2, 'XData', period, 'YData', up); 
    set(temp_plot3, 'XData', period, 'YData', ui); 
    set(temp_plot4, 'XData', period, 'YData', ud); 
    drawnow; 
    
    %Controle de saturação
    if u_now >= max_write
        u_f = max_write;
    elseif u_now <= min_write
        u_f = min_write;
    else
        u_f = u_now;
    end

    end_time = generateVOLT(u_f, ino.hw); %ação de controle (PWM voltage)

    %Comutando variáveis para próxima iteração
    err(2) = err(1); %e[n-2]
    err(1) = err_now; %e[n-1]
    u_past = u_f; %u[n-1] 
    eaw = u_f - u_now;
    
    Ts = period(i) - period(i-1); %atualiza o perído de amostragem
end






