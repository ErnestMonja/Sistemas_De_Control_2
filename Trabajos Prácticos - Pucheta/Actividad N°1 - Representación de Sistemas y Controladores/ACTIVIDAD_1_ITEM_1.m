% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°1:
close all; clear all; history -c; clc;
pkg load control;
pkg load signal;

%   Inicializo las variables dadas como dato por el enunciado:
r = 220;                                   % Resistencia en [Ω].
l = 500*10^(-3);                           % Inductancia en [Hy].
c = 2.2*10^(-6);                           % Capacitancia en [F].

%   Armo las matrices correspondientes a este sistema:
A = [-r/l, -1/l; 1/c, 0];                  % Matriz de Estados.
B = [1/l; 0];                              % Matriz de Entrada.
C = [r, 0];                                % Matriz de Salida.
D = [0];                                   % Matriz de Transmición Directa.

%   Se procede a obtener la función de transferencia del sistema de acuerdo a
% las matrices obtenidas del espacio de estados, como:
[num, den] = ss2tf(A, B, C, D);
G = tf(num, den)

%   Se observa que se trata de un sistema de 2do orden, por lo que se verificará
% cual es el polo dominante de la función:
polos = pole(G)
modulo_polos = abs(real(polos));
polo_dom     = min(modulo_polos)
polo_nod_dom = max(modulo_polos)

%   Se observan 2 polos complejos conjugados de valores: -220 +- j(927,73). Se
% elije como tiempo de muestreo t_r al que responda a las dinámicas más rápidas
% del sistema, para ello el módulo del polo más lejano al orígen de la función
% G(s), si bien es indiferente tomar un polo o el otro se tiene que:
t_r = -log(0.95)/(abs(polo_nod_dom))       % t_r = 2,3315 x 10^(-4) [s]
t_d = abs((2*pi/imag(min(polos)))/100)     % t_d = 6,7726 x 10^(-5) [s]

%   Tomo el menor valor entre t_d y (t_r)/3
t_mues = min(t_r/3, t_d)                   % t_mues = 6,7726 x 10^(-5) [s]

%   Luego el tiempo de simulación t_l se elije en base al polo con la dinámica
% mas lenta y por lo tanto, este tiempo es igual a:
t_l = -log(0.05)/(abs(polo_dom))           % t_l = 0,013617 [s]

%   Se toma aun así el siguiente tiempo de simulación de acuerdo a la consigna:
t_sim = 0.2                                % t_sim = 0,2 [s]

%   Resulta entonces que la cantidad de puntos que tendra nuestra simulación
% será igual a:
punt_tot = t_sim/t_mues                    % punt_tot = 2953,1 [puntos]

%   Inicializo un vector de n números linealmente equiespaciados entre un valor
% inicial y un valor final especificados mediante el comando linspace(), tal que
% definimos a las siguientes variables como:
t = linspace(0, t_sim, punt_tot);
u = linspace(0, 0, punt_tot);

%   Definimos a la entrada de acuerdo a la consigna, esto es una entrada escalón
% de 12V que cambia cada 10ms de signo luego de haber transcurrido unos 0.01 ms,
% tal que:
u(t > 0.01) = 12*(-1).^(floor((t(t > 0.01) - 0.01)/0.01));

%   Esta función u(t>0.01) esta compuesta por una serie que alterna en valores
% negativos con valores positivos gracias al termino (-1)^n donde n se define
% en base a la función floor.

%   Una vez obtenidos los parámetros para la simulación, tendremos que elegir
% las condiciones iniciales del sistema, donde se tendrá que el capacitor no
% tiene una tensión inicial tanto como el inductor no tiene una corriente
% inicial. Además se propone que la salida tampoco contará con un valor inicial,
% tal que:
I(1)  = 0;
Vc(1) = 0;
Vr(1) = 0;
x = [I(1) Vc(1)]';
x0 = [0 0]';                               % Punto de operación

%   Inicializo la simulación y calculamos los valores de las variables para
% cada punto:
for i = 1:(punt_tot-1);
    x_punto = A*(x - x0) + B*u(i);
    x = x + x_punto*t_mues;
    y = C*x;

    %   Actualizo las salidas y demás variables de estado para la próxima
    % iteración:
    Vr(i+1) = y(1);
    I(i+1)  = x(1);
    Vc(i+1) = x(2);
end

%   Finalmente grafico la entrada, salida y demas variables del sistema:
figure(1);

subplot(4,1,1);                            % Grafico la corriente I(t)
plot(t, I);
title('Corriente');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

subplot(4,1,2);                            % Grafico la tensión del capacitor
plot(t, Vc, 'red');                        % Vc(t)
title('Caida de tensión en el capacitor');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

subplot(4,1,3);                            % Grafico la tensión de entrada Ve(t)
plot(t, u, 'blue');                        % = u(t)
title('Tensión de entrada');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

subplot(4,1,4);                           % Grafico la caida de tensión en la
plot(t, Vr, 'green');                     % resistencia Vr(t)
title('Caída de tensión en la resistencia');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on


%----------------------------------O--------------------------------------------

%   Se observa que las corrientes y las tensiones tanto de salida (caída de la
% resistencia) como la de la caída de tensión del capacitor son muy oscilantes.
% Esta oscilación se debe a la elección de parámetros R, L y C del circuito,
% donde si este circuito es simulado en un simulador del tipo QUCS, PSpice o
% Multisim, se obtendrán resultados similares para estas variables.

%   Se tiene que tras estudiar este caso de estudio en algún simulador de
% circuitos, el parámetro de inductor L es quien esta afectando y provocando las
% excesivas oscilaciones. Reducir este parámetro mejora la respuesta del sistema
% y se recomienda modificar este código en la línea 11 para observar tal
% aclaración:

% l = 5*10^(-3)

%   Este cambio de inductancia generará que las variables a medir se asimilen
% bastante más a los gráficos dados por la consigna del ejercicio.
