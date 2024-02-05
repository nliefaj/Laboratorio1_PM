//******************************************************************
/*
Universidad del VAlle de Guatemala
IE2023:Programacion de microcontroladores
Proyecto: Pre-laboratorio1
Creado: 30/01/2024 22:02:45
Autor: lefaj : Nathalie Fajardo
*/
//*******************************************************************

//*******************************************************************
//ENCABEZADO
//*******************************************************************
.include "M328PDEF.inc"
.cseg //comienza el codigo linea 0
.org 0x00
//*******************************************************************
//STACK
//*******************************************************************
LDI R16, LOW(RAMEND)
OUT SPL,R16
LDI R17,HIGH (RAMEND)
OUT SPH, R17
.DEF count=R18
.DEF count2=R19
.DEF sum=R20
.DEF but1=R16
.DEF but2=R16
.DEF but3=R16
.DEF but4=R16
.DEF but5=R16
//*******************************************************************
//CONFIGURACION
//*******************************************************************
setup:
	//RELOJ
	LDI R16, (1<<CLKPCE)
	STS CLKPR,R16 //habilitando prescaler

	LDI R16, 0b0000_0100 //definciendo frecuencia de 1MHz
	STS CLKPR,R16

	//si
	LDI R16, 0b0000_0000
	OUT DDRC, R16 //Set PORTC as input

	LDI R16, 0b1111_1111//Configura el puerto D (LEDS) como salida
	OUT DDRD,R16
	
	LDI R16, 0b0001_1111
	OUT DDRB, R16 //Set PORTB as output

	LDI r16,0b0001_1111 //habilitamos pullup para todos los puertos C (botones)
	OUT PORTC,r16

	LDI r21,0b0000_0000
	LDI r22,0b0000_0000
loop:
	//PRIMER CONTADOR
	IN r16, PINC//PinC presionado o no
	SBRS r16,PC0 
	RJMP btn1

	IN r16, PINC//PinC presionado o no
	SBRS r16,PC1 
	RJMP btn2

	//SEGUNDO CONTADOR
	IN r16, PINC//PinC presionado o no
	SBRS r16,PC2
	RJMP btn3

	IN r16, PINC//PinC presionado o no
	SBRS r16,PC3 
	RJMP btn4

	//SUMA DE CONTADORES
	IN r16, PINC//PinC presionado o no
	SBRS r16,PC4
	RJMP btn5

	RJMP loop//ciclo

//BOTONES
btn1:
	NOP
	CALL delaybounce//espera a que el botón no esté presionado, de lo contrario sigue con el resto
	SBIS PINC, PC0
	JMP btn1
	RJMP incr //llama a etiqueta de incrementar contador

;realiza la misma función con el retso de botones
btn2:
	NOP
	CALL delaybounce
	SBIS PINC, PC1
	JMP btn2
	RJMP decr

btn3:
	NOP
	CALL delaybounce
	SBIS PINC, PC2
	JMP btn3
	RJMP incr2

btn4:
	NOP
	CALL delaybounce
	SBIS PINC, PC3
	JMP btn4
	RJMP decr2

btn5:
	NOP
	CALL delaybounce
	SBIS PINC, PC4
	JMP btn5
	RJMP suma

//DELAY para esperar a que no se tomen más clicks de los necesarios
delaybounce:
	LDI r16,100
	delay:
		DEC r16
		BRNE delay
	RET

incr: //funcion suma
	INC count // le suma +1 al contador
	CPI count,0b0001_0000 //verifica si hay overflow
	BREQ reset // si existe un overflow resetea el contador
	MOV r21,count
	CALL mostrar
	;OUT PORTD,count// muestra el valor del contador
	RJMP loop//regresa al loop

decr:
	DEC count// le resta -1 al contador
	CPI count,0xFF //compara si el contador es igial a 0
	BREQ reset//reinicia el contador a 0
	MOV r21,count
	CALL mostrar
	;OUT PORTD,count// muestra el contador
	RJMP loop//regresa el ciclo inicial

incr2: //funcion suma
	INC count2 // le suma +1 al contador
	CPI count2,0b0001_0000 //verifica si hay overflow
	BREQ reset // si existe un overflow resetea el contador
	MOV r22,count2
	CALL mostrar
	;OUT PORTD,count2// muestra el valor del contador
	RJMP loop//regresa al loop

decr2:
	DEC count2// le resta -1 al contador
	CPI count2,0xFF //compara si el contador es igial a 0
	BREQ reset//reinicia el contador a 0
	MOV r22,count2
	Call mostrar
	;OUT PORTD,count2// muestra el contador
	RJMP loop//regresa el ciclo inicial

suma:
	ADD r21,r22
	LDI r16,0b0001_0000
	CP r21,r16
	BRGE overflow
	OUT PORTB,r21
	RJMP loop
	//BRVS overflow //BRVS-->salta si hay un overflow

//La siguiente función permite que se muestren los valores de contador 1 y 2 juntos
mostrar:
	ANDI r21,0b0000_1111 //revisa que r21 tenga los valores reales del contador 1
	LSL r22
	LSL r22
	LSL r22
	LSL r22//mueve los bits a la izquierda 4 veces
	OR r21,r22//junta ambos contadores
	OUT PORTD,r21//muestra ambos contadores
	//juntar bits de r22 y r21 y as´´i poder hacer un número de 8 bits
	RET 

overflow:
	LDI r16,0b0000_1111
	AND r16,r21//deja los bits menos significativos
	ORI r16,0b00001_0000//añade un bit en cuarta posición para prender el led de overflow
	OUT PORTB,r16//muestra r16
	RJMP loop
	//encender led de overflow y presentar los bits menos significativos de la suma

reset:
	LDI count, 0b0000 //establece el contador en 0
	OUT PORTD, count
	RJMP loop



