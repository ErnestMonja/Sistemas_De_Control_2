% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°4:
close all; clear all; history -c; clc;
pkg load control;
pkg load signal;

%   Cargo el valor de las variables dadas del motor:
Ra  = 55.6;
Laa = 366*10^(-6);
J   = 5*10^(-9);
Bm  = 0;
Ki  = 6.49*10^(-3);
Km  = 6.53*10^(-3);

%   Se tiene que siguiendo las ecuaciones diferenciales dadas en la consigna del
% caso de estudio 2, podemos armar la siguiente representación en variables de
% estado del sistema:
A = [ -Ra/Laa, -Km/Laa,    0 ;  Ki/J,  -Bm/J,   0 ;   0,   1,   0];
B = [  1/Laa ,     0  ;    0 ,  -1/J;   0   ,   0 ];
C = [   0    ,     1  ,    0 ];
D = [   0    ,     0  ];

%   Se tiene que los polos están dados por los valores propios o Eigenvalues
% de la matriz A, por lo tanto:
polos_eig = eig(A)

%   Luego, al igual que como se planteo el item 1, calcularemos los tiempos de
% muestreo y los de simulación en base a la información de los polos. Para ello
% primeramente los definimos:
polo_1 = polos_eig(1)                      % polo_1 = 0
polo_2 = polos_eig(2)                      % polo_2 = -152.60
polo_3 = polos_eig(3)                      % polo_3 = -151760

%   Se elije como tiempo de muestreo t_r al que responda a las dinámicas más
% rápidas del sistema, para ello se utiliza el módulo del polo más cercano al
% orígen (exceptuando polo_1), tal que:
t_r = -log(0.95)/(abs(polo_3))             % t_r = 3.3799 x 10^(-7) [s]

%   Luego el tiempo de simulación t_l se elije en base al polo con la dinámica
% mas lenta y por lo tanto, este tiempo es igual a:
t_l = -log(0.05)/(abs(polo_2))             % t_l = 0.019631 [s]

%   Se toma aun así el siguiente tiempo de simulación y tiempo de muestreo de
% acuerdo a la consigna y basados en un criterio dado por t_r y t_l:
t_sim = 0.2;                               % t_sim = 0,2 [s]
t_mues = 0.0000001;

punt_tot = t_sim/t_mues                    % punt_tot = 2 x 10^(6) [puntos]

%   Inicializo un vector de n números linealmente equiespaciados entre un valor
% inicial y un valor final especificados mediante el comando linspace(), tal que
% definimos a las siguientes variables como:
t  = linspace(0, t_sim, punt_tot);
u  = linspace(0, 0, punt_tot);
Tl = linspace(0, 0, punt_tot);

%   Nótese que se inicializaron u y Tl en 0 para luego habilitarlos con el la
% siguientes líneas de cógido ya analizadas en el item 1:
u (t > 0.01) = 12;
Tl(t > 0.06) = 1.35*10^(-3);

%   El valor de Tl se eligio de acuerdo a la prueba y error de valores, donde
% tras multiples intentos, se determino que Tl = 1.35 x 10^(-3) es el valor de
% torque maximo el cual el motor soporta.

%   Una vez obtenidos los parámetros para la simulación, tendremos que elegir
% las condiciones iniciales del sistema, donde se tendrá que el capacitor no
% tiene una tensión inicial tanto como el inductor no tiene una corriente
% inicial. Además se propone que la salida tampoco contará con un valor inicial,
% tal que:
Ia(1)  = 0;
Wr(1) = 0;
Theta(1) = 0;

x = [Ia(1) Wr(1) Theta(1)]';
x_op = [0 0 0]';

%   Inicializo la simulación y calculamos los valores de las variables para
% cada punto:
for i = 1:(punt_tot-1);
    x_punto = A*(x - x_op) + B*[u(i) Tl(i)]';
    x = x + x_punto*t_mues;
    y = C*x;

    %   Actualizo las salidas y demás variables de estado para la próxima
    % iteración:
    Wr(i+1)  = y(1);
    Ia(i+1) = x(1);
    Theta(i+1) = x(3);
end

%   Finalmente grafico las entradas y salidas del sistema:
figure(1);

subplot(4,1,1);                            % Grafico la velocidad angular Wr(t)
plot(t, Wr);
title('Velocidad Angular Wr');
xlabel('Tiempo [s]');
ylabel('Velocidad Angular [rad/s]');
grid on

subplot(4,1,2);                            % Grafico la corriente Ia(t)
plot(t, Ia, 'red');
title('Corriente de Entrada Ia');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

subplot(4,1,3);                            % Grafico el torque de carga Tl(t)
plot(t, Tl, 'blue');
title('Torque de Carga Tl');
xlabel('Tiempo [s]');
ylabel('Newton por Metro [N.m]');
grid on

subplot(4,1,4);                            % Grafico ángulo de giro Theta(t)
plot(t, Theta, 'green');
title('Angulo de giro');
xlabel('Tiempo [s]');
ylabel('Angulo [rad]');
grid on
