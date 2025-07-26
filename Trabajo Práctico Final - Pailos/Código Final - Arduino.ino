// Incluir librerías para el LCD con I2C
#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>

// Inicializar el LCD (dirección I2C 0x27 es común, 16 columnas, 2 filas)
LiquidCrystal_PCF8574 lcd(0x27);

// Definición de pines
const int buttonAddMeters = 7;  // Botón para añadir +2 metros (10 cuentas)
const int buttonPlayStop = 8;   // Botón de inicio/parada
const int irSensorPin = 2;      // Pin del sensor HW-201 (digital)
const int motorPinIN1 = 13;     // Pin IN1 del L298N
const int motorPinIN2 = 12;     // Pin IN2 del L298N (PWM)
const int motorPinENA = 6;      // Pin ENA del L298N (PWM)
const int MAX_COUNT = 9990;     // Límite máximo del contador
const int METERS_TO_COUNT = 10; // 2 metros = 10 cuentas
const int RAMP_TIME = 100;     // 1 segundo para rampa de motor (ms)

// Variables para el sensor HW-201
volatile int counter = 0;        
volatile unsigned long lastIrTime = 0; 
const long irDebounceDelay = 50; 
volatile int irPulseCount = 0;  // Para contar las señales del sensor

int state = 1;  // Estado: 1 (Esperando), 2 (En marcha), 3 (Listo)
int lastAddButtonState = HIGH;
int lastPlayStopState = HIGH;
unsigned long lastDebounceTime = 0;
const long debounceDelay = 50;
unsigned long rampStartTime = 0;
bool motorStopping = false;
bool panicStop = false;
bool lastIrState = LOW;
int lastCounter = -1;
int lastState = -1;
int cont_final = 0;  // Valor del contador al iniciar enrollado

// Para alternar mensajes en estado 3
unsigned long lastToggleTime = 0;
bool toggleMessage = false;

// Acelerar/desacelerar motor suavemente
void rampMotorSpeed(int startSpeed, int targetSpeed, unsigned long duration) {
  unsigned long startTime = millis();
  unsigned long elapsed = 0;
  while (elapsed < duration) {
    elapsed = millis() - startTime;
    int speed = startSpeed + (targetSpeed - startSpeed) * elapsed / duration;
    speed = constrain(speed, 0, 255);
    analogWrite(motorPinENA, speed);
    delay(10);
  }
  analogWrite(motorPinENA, targetSpeed);
}

// Detener motor suavemente y resetear a Estado 1 o pasar a 3
void stopMotor(bool resetCounter) {
  motorStopping = true;
  rampMotorSpeed(255, 0, RAMP_TIME);
  digitalWrite(motorPinIN1, LOW);
  digitalWrite(motorPinIN2, LOW);
  analogWrite(motorPinENA, 0);

  if (resetCounter) {
    counter = 0;
  }

  if (!panicStop) {
    state = 3;  // Terminado normalmente → estado listo
    lastToggleTime = millis();  // Reiniciar el temporizador de alternancia
  } else {
    state = 1;  // Parada de emergencia → volver a espera
  }

  motorStopping = false;
  panicStop = false;
  Serial.println("Motor detenido");
}

// Procesar sensor HW-201
void processIrSensor() {
  int irValue = digitalRead(irSensorPin);
  unsigned long currentTime = millis();

  if (irValue == HIGH && lastIrState == LOW && (currentTime - lastIrTime > irDebounceDelay)) {
    if (state == 2 && !motorStopping && !panicStop) {
      irPulseCount++;
      if (irPulseCount >= 2) {  // Solo contamos después de 2 pulsos (1 vuelta completa)
        irPulseCount = 0;       // Reiniciar el contador de pulsos
        counter--;
        Serial.print("Contador: ");
        Serial.println(counter);
        if (counter <= 0) {
          counter = 0;
          motorStopping = true;
          rampStartTime = millis();
        }
      }
    }
    lastIrTime = currentTime;
  }
  lastIrState = irValue;
}

// Actualizar el LCD
void updateLCD() {
  if (state == 3) {
    // Alternar mensajes cada 1 segundo
    if (millis() - lastToggleTime >= 2000) {
      toggleMessage = !toggleMessage;
      lcd.clear();
      lcd.setCursor(0, 0);
      if (toggleMessage) {
        lcd.print("Pulse el Boton");
        lcd.setCursor(0, 1);
        lcd.print("Rojo para volver");
      } else {
        lcd.print("Estan listas sus");
        lcd.setCursor(0, 1);
        lcd.print(cont_final);
        lcd.print(" vueltas");
      }
      lastToggleTime = millis();
    }
    return; // No continuar con el resto
  }

  if (lastCounter != counter || lastState != state) {
    lcd.clear();
    lcd.setCursor(0, 0);
    if (state == 1) {
      lcd.print("Definir cantidad");
    } else if (state == 2 && !motorStopping && !panicStop) {
      lcd.print("Vueltas");
    } else {
      lcd.print("Deteniendo");
    }

    lcd.setCursor(0, 1);
    if (state == 1) {
      lcd.print("de vueltas: ");
      lcd.print(counter);
    } else if (state == 2 && !motorStopping && !panicStop) {
      lcd.print("restantes: ");
      lcd.print(counter);
    } else {
      lcd.print("el motor...");
    }

    lastCounter = counter;
    lastState = state;
  }
}

void setup() {
  Serial.begin(9600);
  Serial.println("Iniciando sistema con HW-201 y LCD...");

  lcd.begin(16, 2);
  lcd.setBacklight(255);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Iniciando...");
  delay(1000);

  pinMode(buttonAddMeters, INPUT_PULLUP);
  pinMode(buttonPlayStop, INPUT_PULLUP);
  pinMode(irSensorPin, INPUT);
  pinMode(motorPinIN1, OUTPUT);
  pinMode(motorPinIN2, OUTPUT);
  pinMode(motorPinENA, OUTPUT);

  digitalWrite(motorPinIN1, LOW);
  digitalWrite(motorPinIN2, LOW);
  analogWrite(motorPinENA, 0);

  updateLCD();
}

void loop() {
  processIrSensor();

  int addButtonState = digitalRead(buttonAddMeters);
  int playStopState = digitalRead(buttonPlayStop);

  if (addButtonState != lastAddButtonState && (millis() - lastDebounceTime) > debounceDelay) {
    if (addButtonState == LOW && state == 1) {
      counter += METERS_TO_COUNT;
      if (counter > MAX_COUNT) {
        counter = MAX_COUNT;
      }
      Serial.print("Metros añadidos, contador: ");
      Serial.println(counter);
    }
    lastDebounceTime = millis();
  }
  lastAddButtonState = addButtonState;

  if (playStopState != lastPlayStopState && (millis() - lastDebounceTime) > debounceDelay) {
    if (playStopState == LOW) {
      if (state == 1 && counter > 0) {
        state = 2;
        cont_final = counter;  // Guardar el valor del contador
        motorStopping = false;
        panicStop = false;
        digitalWrite(motorPinIN1, HIGH);
        digitalWrite(motorPinIN2, LOW);
        rampStartTime = millis();
        rampMotorSpeed(0, 255, RAMP_TIME);
        Serial.println("Motor iniciado");
      } else if (state == 2) {
        panicStop = true;
        stopMotor(true);
      } else if (state == 3) {
        // Reiniciar
        counter = 0;
        state = 1;
        Serial.println("Sistema reiniciado");
      }
    }
    lastDebounceTime = millis();
  }
  lastPlayStopState = playStopState;

  if (state == 2 && motorStopping && !panicStop) {
    if (millis() - rampStartTime >= RAMP_TIME) {
      digitalWrite(motorPinIN1, LOW);
      digitalWrite(motorPinIN2, LOW);
      analogWrite(motorPinENA, 0);
      state = 3;  // Ahora pasa a estado 3
      lastToggleTime = millis();
      Serial.println("Motor detenido por contador = 0");
    }
  }

  updateLCD();
}