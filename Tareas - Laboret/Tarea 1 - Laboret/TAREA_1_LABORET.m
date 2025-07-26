close all; clear all; history -c; clc;
pkg load control;
pkg load symbolic;

% Datos dados por la tabla:
p1 = -3;
p2 = -2;
K = 10;
Sobrepaso = 15;
t_2percent = 3;
error = 0;
T = 0.07;

% Obtener la función de transferencia continua G(s).
G = zpk([],[p1 p2],[K])
Tm = T

% Hallar la FT discreta de lazo abierto Gd(s) del sistema de la figura con Z0H
% a la entrada y el tiempo de muestreo asignado Tm.
Gd = c2d(G, Tm, 'Z0H')

% Dibujar el mapa de polos y ceros del sistema continuo y el discreto
figure(1); pzmap(G)
figure(2); pzmap(Gd)

% ¿Qué ocurre con el mapa si se multiplica por 10 el periodo de muestreo?
Gd1 = c2d(G, 10*Tm, 'Z0H')
figure(3); pzmap(Gd1)

% Obtener la respuesta al escalon del sistema discreto y determinar si es
% estable.
figure(4); step(G)
figure(5); step(Gd)

%                           Para el sistema discreto                           %
% Determinar el tipo de sistema.
% En este caso se trata de un sistema tipo 0.

% Determinar la constante de error de posición Kp y el error ante un escalon, y
% verificar mediante respuesta al escalon de lazo cerrado del sistema discreto
% como se muestra:
Kp = dcgain(Gd)
ess = 1/(1 + Kp)
GdLC = feedback(Gd,1)
figure(6); step(GdLC)

% Verificar error ante una rampa de entrada, ¿ converge o diverge? Explique la
% causa
t = 0:Tm:100*Tm;         % genera rampa
figure(7); lsim(GdLC,t,t)

%                    A lazo cerrado con realimentación unitaria                %
% Graficar el lugar de raíces del sistema continuo G(s) y del sistema discreto
% Gd(s) indicando las ganancias criticas de estabilidad (si las hubiera)
figure(8); rlocusx(G)
figure(9); rlocusx(Gd)

% ¿Qué ocurre con la estabilidad relativa si se aumenta 10 veces el tiempo de
% muestreo original?
figure(10); rlocusx(Gd1)
