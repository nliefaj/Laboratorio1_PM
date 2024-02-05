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

	LDI r16, (1<<PC0)
	OUT PORTC,r16
	CBI DDRC, PC0 ;Configura el pin PC0/A0 como entrada
	/*
	LDI r16, (1<<PC1)
	OUT PORTC,r16
	CBI DDRC, PC1 ;Configura el pin PC1/A1 como entrada

	LDI r16, (1<<PC2)
	OUT PORTC,r16
	CBI DDRC, PC2 ;Configura el pin PC2/A2 como entrada

	LDI r16, (1<<PC0)
	OUT PORTC,r16
	CBI DDRC, PC0 ;Configura el pin PC0/A0 como entrada*/

	LDI r16, (1<<PD0)
	OUT DDRD,r16 ;Configuro el pin PD0 como salida

	LDI r16, (1<<PD1)
	OUT DDRD,r16 ;Configuro el pin PD1 como salida

	LDI r16, (1<<PD2)
	OUT DDRD,r16 ;Configuro el pin PD2 como salida

	LDI r16, (1<<PD3)
	OUT DDRD,r16 ;Configuro el pin PD3 como salida


	//MI PROGRA
	/*LDI R16, 0b0001_1111
	OUT DDRC, R16 //Set PORTC as input

	LDI R16, 0b0000_0000//Configura el puerto D (LEDS) como salida
	OUT DDRD,R16*/

	LDI count, 0b0000
	OUT DDRD, count
	
	LDI count2, 0b0000
	OUT DDRD, count

	LDI r21,0b0000_0000
	LDI r22,0b0000_0000
loop:
	//PRIMER CONTADOR
	IN r16, PORTC//PORTC=1
	SBRS r16,PC0 
	RJMP delaybounce

	RJMP loop

	CPI but1,0b0001//si lee esto, entonces esta presionando el boton de incrementar contador
	BREQ incr // manda a llamar a la fuincion incr-->incrementa el contador
	
	IN but2, PORTC // compara la entrada del pinA, si es el segundo entonces lo asigna a b2
	//SBRS R16,PC1 ;salta si alguno de los botones no esta presionado
	//RJMP delaybounce

	CPI but2,0b0010// decrece el contador porque el boton está presionado
	BREQ decr// manda a llamar a la funcion decr--> disminuye el contador

	//SEGUNDO CONTADOR
	//SBRS R16,PC0;salta si alguno de los botones no esta presionado
	//RJMP delaybounce
	IN but3, PORTC//PORTC=1
	CPI but3,0b0100//si lee esto, entonces esta presionando el boton de incrementar contador
	BREQ incr2 // manda a llamar a la fuincion incr-->incrementa el contador
	
	IN but4, PORTC // compara la entrada del pinA, si es el segundo entonces lo asigna a b2
	//SBRS R16,PC1 ;salta si alguno de los botones no esta presionado
	//RJMP delaybounce

	CPI but4,0b1000// decrece el contador porque el boton está presionado
	BREQ decr2// manda a llamar a la funcion decr--> disminuye el contador

	//SUMA DE CONTADORES
	in but5,PORTC
	CPI but5,0b0001_0000
	BREQ suma


	RJMP loop//ciclo
delaybounce:
	LDI r16,100
	delay:
		DEC r16
		BRNE delay

	SBIS PINC,PC0
	RJMP delaybounce

	SBI PIND,PD0
	RJMP loop

incr: //funcion suma
	INC count // le suma +1 al contador
	CPI count,0b0001_0000 //verifica si hay overflow
	//aqui deberia de añadir un carryflag
	BREQ reset // si existe un overflow resetea el contador
	MOV r21,count
	CALL mostrar
	;OUT PORTD,count// muestra el valor del contador
	RJMP loop//regresa al loop

mostrar:
	LSL r22
	LSL r22
	LSL r22
	LSL r22
	OR r21,r22
	OUT PORTD,r21
	//juntar bits de r22 y r21 y as´´i poder hacer un número de 8 bits
	RET

decr:
	DEC count// le resta -1 al contador
	CPI count,0b0000 //compara si el contador es igial a 0
	//aqui deberia de añadir un zeroflag
	BREQ reset//reinicia el contador a 0
	MOV r21,count
	CALL mostrar
	;OUT PORTD,count// muestra el contador
	RJMP loop//regresa el ciclo inicial

incr2: //funcion suma
	INC count2 // le suma +1 al contador
	CPI count2,0b0001_0000 //verifica si hay overflow
	//aqui deberia de añadir un carryflag
	BREQ reset // si existe un overflow resetea el contador
	MOV r22,count2
	CALL mostrar
	;OUT PORTD,count2// muestra el valor del contador
	RJMP loop//regresa al loop

decr2:
	DEC count2// le resta -1 al contador
	CPI count2,0b0000 //compara si el contador es igial a 0
	//aqui deberia de añadir un zeroflag
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

overflow:
	LDI r16,0b0000_1111
	AND r16,r21
	ORI r16,0b00001_0000
	OUT PORTB,r16
	RJMP loop
	//encender led de overflow y presentar los bits menos significativos de la suma

reset:
	LDI count, 0b0000 //establece el contador en 0
	OUT PORTD, count
	RJMP loop

/*delaybounce:
	LDI R16,100
	delay:
		DEC R16
		BRNE delay
	
	SBIS PORTC,PC0
	RJMP delaybounce

	SBIS PORTC,PC1
	RJMP delaybounce

	SBI PORTD,PD0
	SBI PORTD,PD1
	SBI PORTD,PD2
	SBI PORTD,PD3

	RJMP loop*/


