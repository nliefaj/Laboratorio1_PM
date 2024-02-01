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
.DEF but1=R19
.DEF but2=R20
//*******************************************************************
//CONFIGURACION
//*******************************************************************
setup:
/*
	LDI R16, (1<<CLKPCE)
	STS CLKPR,R16 //habilitando prescaler

	LDI R16, 0b0000_0100
	STS CLKPR,R16

	LDI R16, 0b0001_1111
	OUT DDRC, R16 //Set PORTC as input

	LDI R16, 0b0000_0000//Configura el puerto D (LEDS) como salida
	OUT DDRD,R16
*/

	LDI count, 0b000
	OUT DDRD, count

loop:
	
	//IN but1, PC0
	//SBRS R16,PC0;salta si alguno de los botones no esta presionado
	//RJMP delaybounce

	CPI but1,0//si lee esto, entonces esta presionando el boton de incrementar contador
	BREQ incr // manda a llamar a la fuincion incr-->incrementa el contador
	
	IN but2, PC1 // compara la entrada del pinA, si es el segundo entonces lo asigna a b2
	//SBRS R16,PC1 ;salta si alguno de los botones no esta presionado
	//RJMP delaybounce

	CPI but2,0// decrece el contador porque el boton está presionado
	BREQ decr// manda a llamar a la funcion decr--> disminuye el contador

	RJMP loop//ciclo

incr: //funcion suma
	INC count // le suma +1 al contador
	CPI count,0b0001_0000 //verifica si hay overflow
	//aqui deberia de añadir un carryflag
	BREQ reset // si existe un overflow resetea el contador
	OUT PORTD,count// muestra el valor del contador
	RJMP loop//regresa al loop

decr:
	DEC count// le resta -1 al contador
	CPI count,0b0000 //compara si el contador es igial a 0
	//aqui deberia de añadir un zeroflag
	BREQ reset//reinicia el contador a 0
	OUT PORTD,count// muestra el contador
	RJMP loop//regresa el ciclo inicial

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


