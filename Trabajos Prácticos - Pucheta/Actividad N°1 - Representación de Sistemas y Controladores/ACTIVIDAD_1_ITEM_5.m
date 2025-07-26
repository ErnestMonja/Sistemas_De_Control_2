% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°5:
close all; clear all; history -c; clc;
pkg load control;
pkg load io;
%   Recuerde instalar el paquete IO de no tenerlo instalado, esto es:
% pkg install -forge io

%   Como indica la consigna, se tiene que leer los archivos guardados en un
% archivos de Excel en formato .xls, al cual se paso a .xlsx para poder
% trabajarlo en Octave y se guardaron los datos de la tabla en las siguientes
% variables:
data = xlsread('Curvas_Medidas_Motor_2025_v.xlsx');
    t  = data(1:1500, 1);        % Tiempo.
    Wr = data(1:1500, 2);        % Velocidad angular.
    Ia = data(1:1500, 3);        % Corriente de armadura.
    Va = data(1:1500, 4);        % Tensión de alimentación (Va(t) = u(t)).
    Tl = data(1:1500, 5);        % Torque de carga.

%   Realizo los gráficos de las variables dadas en el archivo de excel para
% observar el comportamiento del sistema:
figure(1);
subplot(4,1,1);                            % Grafico la velocidad angular Wr(t)
plot(t, Wr);
title('Velocidad Angular (Wr)');
xlabel('Tiempo [s]');
ylabel('Velocidad Angular [rad/s]');
grid on

subplot(4,1,2);                            % Grafico la corriente Ia(t)
plot(t, Ia, 'red');
title('Corriente de Entrada (Ia)');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

subplot(4,1,3);                            % Grafico la tensión de alimentación
plot(t, Va, 'green');                      % Va(t)
title('Tensión de entrada (Va)');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

subplot(4,1,4);                            % Grafico el torque de carga Tl(t)
plot(t, Tl, 'blue');
title('Torque de Carga (Tl)');
xlabel('Tiempo [s]');
ylabel('Newton por Metro [N.m]');
grid on

%   Las gráficas obtenidas de acuerdo a las tablas de Excel (¡Nótese que se esta
% usando el archivo que termina en "_v"!) nos plantean unas gráficas que difieren
% a las presentadas en la consigna a modo de guía, sin embargo no resultan
% ningún impedimento a la hora de resolver este item.

%   La consigna nos plantea, de forma similar al item 2, encontrar todos los
% parámetros del motor, sin embargo a diferencia del item 2, en este caso
% contamos con mas parámetros que obtener pero a su vez un sistema con 1 entrada
% Va(t), 1 salida Wr(t) y la perturbación Tl(t) que puede ser considerada como
% una entrada. Para resolver este ejercicio, buscaremos plantear múltiples
% funciones de transferencia mediante el metodo de Chen y comparar las
% constantes T1, T2 y T3 para obtener los parámetros del circuito.

%   Al igual que se hizo para el sistema del Item 2, es conveniente transformar
% la salida del sistema Wr(t) a una forma donde no se tenga el retardo propio
% de 0.1 [s] y que termine antes de que se aplique el torque, con el fin de
% poder plantear la primer función de trasnferencia que sera: Wr(s)/Va(s). Para
% ello se plantea lo siguiente:
delay = 0.1;
ind_util = find(t >= 0.1 & t <= 0.7);
t_util = t(ind_util) - delay;
Wr_util = Wr(ind_util);

%   Grafico a Wr_util:
figure(2);
plot(t_util, Wr_util, 'red');
title('Velocidad angular del motor (respuesta a una entrada de 2V)');
xlabel('Tiempo [s]');
ylabel('Velocidad angular [rad/s]');
grid on

%   Wr_util representa la salida de nuestro sistema sin retardos y sin cambios
% dados por el Torque de Carga. Dada la salida Wr_util aplicaremos el ya
% estudiado el método de Chen, el cual nos dice que debemos elegir 3 puntos
% igualmente espaciados para aplicar su método. Para ello y observando la tabla
% del Excel + gráficos, vemos que para:

%      t = 0,101 [s] ---> y(t) = Wr(t) = 0 [rad/s]
%      t = 0,280 [s] ---> y(t) = Wr(t) = 6,504515101 [rad/s]
%      t = 0,599 [s] ---> y(t) = Wr(t) = 7,600732618 [rad/s]
%      t = 0,700 [s] ---> y(t) = Wr(t) = 7,624606709 [rad/s]

%   Se observa que donde ocurre el transitorio de al función se da en el
% intervalo [0,1 ; 0,4] donde se tienen 500 valores según la tabla de excel de
% entremedio. Se proponen los siguientes puntos de operación para el método de
% Chen:
t1_Wr_Va  = data(135,1) - delay;  % 135,170,205 -> BUENA APROXIMACION? buscar mejor.
y1_Wr_Va  = data(135,2);

t2_Wr_Va  = data(170,1) - delay;
y2_Wr_Va  = data(170,2);

t3_Wr_Va  = data(205,1) - delay;
y3_Wr_Va  = data(205,2);

%   Se selecciona un 4to punto de operación. Esto es debido a que el método de
% Chen solo funciona para y(inf) = 1 lo que implica una K = 1. Para ello es
% conveniente elegir el punto justo antes que la gráfica de Wr(t) reciba el
% torque de carga, y eso ocurre en t = 0,07 [s] tal que:
tss_Wr_Va = data(700,1) - delay;
yss_Wr_Va = data(700,2);

%   Luego solo resta aplicar el algoritmo de Chen utilizando las siguientes
% fórmulas obtenidas de su artículo, tal que:
K_Wr_Va   = (yss_Wr_Va / 2);
k1_Wr_Va  = ((y1_Wr_Va / 2) / K_Wr_Va) - 1;
k2_Wr_Va  = ((y2_Wr_Va / 2) / K_Wr_Va) - 1;
k3_Wr_Va  = ((y3_Wr_Va / 2) / K_Wr_Va) - 1;

b_Wr_Va       = 4 * (k1_Wr_Va^3) * k3_Wr_Va  - 3 * (k1_Wr_Va^2) * (k2_Wr_Va^2) - 4 * (k2_Wr_Va^3) + k3_Wr_Va^2 + 6 * (k1_Wr_Va) * (k2_Wr_Va) * (k3_Wr_Va);
alpha1_Wr_Va  = (k1_Wr_Va * k2_Wr_Va + k3_Wr_Va - sqrt(b_Wr_Va))/(2 * (k1_Wr_Va^2 + k2_Wr_Va));
alpha2_Wr_Va  = (k1_Wr_Va * k2_Wr_Va + k3_Wr_Va + sqrt(b_Wr_Va))/(2 * (k1_Wr_Va^2 + k2_Wr_Va));
beta_Wr_Va    = (k1_Wr_Va + alpha2_Wr_Va)/(alpha1_Wr_Va - alpha2_Wr_Va);

T1_Wr_Va  = real((-t1_Wr_Va/log(alpha1_Wr_Va)));
T2_Wr_Va  = real((-t1_Wr_Va/log(alpha2_Wr_Va)));
T3_Wr_Va  = real((beta_Wr_Va*(T1_Wr_Va - T2_Wr_Va) + T1_Wr_Va));

%   Una vez obtenidas las constantes T1, T2 y T3, se tiene que la función de
% transferencia es igual a:
s = tf('s');
%FdT_CHEN = (K_Wr_Va*(s*T3_Wr_Va + 1))/((s*T1_Wr_Va + 1)*(s*T2_Wr_Va + 1))
FdT_CHEN = K_Wr_Va/((s*T1_Wr_Va + 1)*(s*T2_Wr_Va + 1))
FdT_CHEN_RESP = step(2*FdT_CHEN, t_util);

%   Se propone ver como difiere la aproximación con la salida original dada por
% Vc_util desde el Excel, esto es:
figure(3);
plot(t_util, FdT_CHEN_RESP, 'green', t_util, Wr_util, 'red');
title('Velocidad angular de CHEN');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
legend('Respuesta obtenida por el método de Chen', 'Respuesta Original obtenida del Excel');
grid on;

%   Resulta entonces que esta aproximación de Chen es lo suficientemente correcta
% para aproximar las curvas obtenidas, tal que si comparamos la función de
% transferencia obtenida por con la que tiene un motor


