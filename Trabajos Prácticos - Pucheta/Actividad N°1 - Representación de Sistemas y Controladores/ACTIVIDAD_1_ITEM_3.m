% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°3:
close all; clear all; history -c; clc;
pkg load signal;
pkg load io;
%   Recuerde instalar el paquete IO de no tenerlo instalado, esto es:
% pkg install -forge io

%   Como indica la consigna, se tiene que leer los archivos guardados en un
% archivos de Excel en formato .xls, al cual se paso a .xlsx para poder
% trabajarlo en Octave y se guardaron los datos de la tabla en las siguientes
% variables:
data = xlsread('Curvas_Medidas_RLC_2025.xlsx');
    t    = data(501:end, 1);        % Tiempo.
    I_0  = data(501:end, 2);        % Corriente en el circuito.
    Ve_0 = data(501:end, 4);        % Tensión de alimentación (Ve(t) = u(t)).

%   Realizo los gráficos de las variables dadas en el archivo de excel para
% observar el comportamiento del sistema:
figure(1);
subplot(2,1,1);                 % Grafico la corriente I(t)
plot(t, I_0, 'red');
title('Corriente');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

subplot(2,1,2);                  % Grafico la tensión de entrada Ve(t) = u(t)
plot(t, Ve_0, 'blue');
title('Tensión de entrada');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

%   Utilizando los parametros del item anterior se tiene que:
r = 220;
l = 1.9592*10^(-3);
c = 2.2305*10^(-6);

%   Se armaron las matrices y luego procedo a obtener la función de transferencia
% talcomo se obtuvo en el Item 1 de esta actividad:
A = [-r/l, -1/l; 1/c, 0];         % Matriz de Estados.
B = [1/l; 0];                     % Matriz de Entrada.
C = [r, 0];                       % Matriz de Salida.
D = [0];                          % Matriz de Transmición Directa.
[num, den] = ss2tf(A, B, C, D);
G = tf(num, den)

%   Nótese que en este caso, dada la respuesta del circuito, se tienen los
% siguientes polos:
polos = pole(G)

%   Se tiene que ahora haremos coincidir el tiempo de muestreo y el de la
% simulación para ambas funciones, ademas de que consideraremos los valores de
% corriente a partir de los 0.05 [s], tal que:
t_mues = 0.00001;
t_sim = 0.2;
punt_tot = t_sim/t_mues - 500;    % punt_tot = 19500 [puntos]

%   Una vez obtenidos los parámetros para la simulación, tendremos que elegir
% las condiciones iniciales del sistema, donde se tendrá que el capacitor no
% tiene una tensión inicial ni el inductor no tiene una corriente inicial,
% tal que:
I(1)  = 0;
Vc(1) = 0;
y(1)  = 0;
x = [I(1) Vc(1)]';
x0 = [0 0]';

%   Inicializo la simulación y calculamos los valores de las variables para
% cada punto:
for i = 1:(punt_tot);
    x_punt = A*(x - x0) + B*Ve_0(i);
    x = x + x_punt*t_mues;

    %   Actualizo la corriente para la próxima iteración:
    I(i+1) = x(1);
end

%   Finalmente superpongo las gráficas (la obtenida por la tabla de Excel y la
% obtenida por el método de Chen en el item 2):
figure(2);
plot(t, I_0, 'green', t, I, 'red');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
title('Gráfica comparativa entre la Corriente deducida en el Item 2 y la obtenida por Excel');
legend('Respuesta del Excel', 'Respuesta del Item 2')
grid on;


%----------------------------------O--------------------------------------------

%   Se observa que la gráfica de la corriente obtenida por el método de Chen es
% practicamente la misma que la que se obtiene por los datos del documento de
% Excel, verificando así que el item 2 fue correctamente realizado y se verifico
% en este item. Con este item se concluye el estudio del caso 1 del circuito RLC
% siendo una introducción a los ejercicios de variables de estado muy útil.
