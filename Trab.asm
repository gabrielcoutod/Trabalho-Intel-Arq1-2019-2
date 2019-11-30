; Gabriel Couto Domingues 00302229

	.model		small
	.stack

; CONSTANTES 
CR		equ		0dh ; CARRIAGE RETURN
LF		equ		0ah ; LINE FEED
pos_inicial_x equ 	8 ; posicao inicial para desenhar parede
pos_inicial_y equ 	26 ; poiscao inicial para desenhar parede
MAXSTRING	equ		200 ; string maxima

	.data
; variaveis de arquivos
FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleSrc	dw		0				; Handler do arquivo origem
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo

;mensagens do programa
MsgInicio 	db "Aluno: Gabriel Couto Domingues Matricula: 302229", CR, LF, 0 
MsgFim 	db "Programa Encerrado", CR, LF, 0 
MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF				db	CR, LF, 0
Msgarquivo 	db "Arquivo ",0
Msgarquivo2 	db " - Total de ladrilhos por cor:",0


String	db	MAXSTRING dup (?) ; Usado na funcao gets
Ponto 	db 	0 ; para saber se tem ponto a string de entrada(booleano)

Contadores 	dw 	16 dup(?); contadores da parede

; variaveis para converter numero para string
string_contador db	10 dup (?)
H2D		db	10 dup (?)
sw_n	dw	0
sw_f	db	0
sw_m	dw	0


ContAtual dw 0 

cor_caixa db 0 

;booleano para saber se tem que desenhar
Desenhar dw 0 

; tamanho do lado do quadrado
lado_quadrado dw 0 


; informacoes da posicao atual do quadrado
x_atual dw 0
y_atual dw 0 

; mostra a posicao atual do quadrado
; para saber quando trocar de linha
quadrado_pos dw 0 


pos_x_contador db 0
pos_y_contador db 0

; informacoes da parede
string_linha db 0,0,0

string_coluna db 0,0,0

cor_atual db 0 

linha dw 0
coluna dw 0 

Preto db 'Preto – ',0
tPreto dw $-Preto -1

Azul db 'Azul – ',0
tAzul dw $-Azul -1

Verde db 'Verde – ',0
tVerde dw $-Verde -1

Ciano db 'Ciano – ',0
tCiano dw $-Ciano -1

Vermelho db 'Vermelho – ',0
tVermelho dw $-Vermelho -1

Magenta db 'Magenta – ',0
tMagenta dw $-Magenta -1

Marrom db 'Marrom – ',0
tMarrom  dw $-Marrom -1

Cinza_claro db 'Cinza claro – ',0
tCinza_claro dw $-Cinza_claro -1

Cinza_escuro db 'Cinza escuro –' ,0
tCinza_escuro dw $-Cinza_escuro -1

Azul_claro db 'Azul claro – ',0
tAzul_claro dw $-Azul_claro-1 

Verde_claro db 'Verde claro – ',0
tVerde_claro dw $-Verde_claro-1 

Ciano_claro db 'Ciano claro – ',0
tCiano_claro dw $-Ciano_claro-1

Vermelho_claro db'Vermelho claro – ',0
tVermelho_claro dw $-Vermelho_claro-1

Magenta_claro db 'Magenta claro – ',0
tMagenta_claro dw $-Magenta_claro-1

Amarelo db 'Amarelo – ',0
tamarelo dw $-amarelo-1




	.code
	.startup

	
Inicio:
	;limpa tela
	call clrscr


	;coloca es = ds
	mov	 	bx,ds
	mov 	es,bx

	;direcao = 0
	cld

	;cursor no inicio
	mov  dl, 0
	mov  dh, 0
	call set_cursor


	;Mensagem de inicio
	lea		bx,MsgInicio
	call	printf_s
ERRO_ARQUIVO:

	;zera contadores
	call limpa_contadores

	;limpa string linha e coluna
	mov string_linha,0
	mov string_linha+1,0
	mov string_coluna,0
	mov string_coluna+1,0

	;GetFileNameSrc();	// Pega o nome do arquivo de origem -> FileNameSrc
	call	GetFileNameSrc

	; verifica se foi digitado apenas enter
	cmp string+1,0
	jne continua0

	; so foi digitado enter
	lea		bx,MsgFim
	call	printf_s
	.exit 0 



continua0:
	
	lea		dx,FileNameSrc ;tenta abrir o arquivo
	call	fopen
	mov		FileHandleSrc,bx
	jnc		cria_arquivo ; verifica se deu erro
	lea		bx, MsgErroOpenFile
	call	printf_s
	jmp 	ERRO_ARQUIVO 


cria_arquivo:
	
	;GetFileNameDst();	// Pega o nome do arquivo de origem -> FileNameDst
	call	GetFileNameDst

	lea		dx,FileNameDst; tenta criar arquivo
	call	fcreate
	mov		FileHandleDst,bx
	jnc		le_dimensao ; verifica se ocorreu erro
	lea		bx, MsgErroCreateFile
	call	printf_s
	jmp 	ERRO_ARQUIVO

le_dimensao:
	; le primeiro caractere
	mov		bx,FileHandleSrc
	call	getChar
	jc		erro_dimensao
	mov 	string_linha,dl

	; le segundo ou virgula
	call	getChar
	jc		erro_dimensao
	cmp 	dl,','
	je		achou_virgula
	mov 	string_linha+1,dl

	call	getChar
	jc		erro_dimensao
	cmp 	dl,','
	je		achou_virgula

achou_virgula:
	; le primeiro char da segunda dimensao
	call	getChar
	jc		erro_dimensao
	mov 	string_coluna,dl

	; le segundo char ou CR
	call	getChar
	jc		erro_dimensao
	cmp 	dl,CR
	je		guarda_dimensao

	mov 	string_coluna+1,dl
	jmp 	guarda_dimensao

erro_dimensao:
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc ; fecha arquivos
	call	fclose
	mov		bx,FileHandleDst
	call	fclose
	jmp ERRO_ARQUIVO

guarda_dimensao:
	lea bx,string_linha ; converte a string linha para numero
	call atoi 
	mov linha,ax

	lea bx,string_coluna  ; converte a string coluna para numero
	call atoi
	mov coluna,ax

	;calcula tam do quadrado
	call tam_quadrado

	; inicializa posicao do quadrado
	mov quadrado_pos,0
	mov x_atual,pos_inicial_x
	mov y_atual,pos_inicial_y


	;troca para modo grafico
	mov ah,0
	mov al,12h
	int 10h


	; coloca cursor no inico
	mov  dl, 0             
	mov  dh, 0               
	call set_cursor

	; mensagem de inicio
	lea		bx,MsgInicio
	call	printf_s

	; desenha borda amarela
	call desenha_caixa


Continua1:

	mov		bx,FileHandleSrc ; le caractere
	call	getChar
	jnc		Continua2	; verifica erro

	;limpa tela
	call clrscr

	;cursor no inicio
	mov  dl, 0
	mov  dh, 0
	call set_cursor

	;Mensagem de inicio
	lea		bx,MsgInicio
	call	printf_s

	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc	; fecha rquivos
	call	fclose
	mov		bx,FileHandleDst
	call	fclose
	jmp 	ERRO_ARQUIVO
Continua2:

	;	if (AX==0) break;
	cmp		ax,0
	jz		continua3
	
	call 	incrementaContador
	call 	desenha_quadrado
	jmp 	continua1
Continua3:
	; fecha arquivo com as paredes
	mov		bx,FileHandleSrc
	call	fclose

	mov lado_quadrado,24	; escreve dados das pardes na tela
	call escreve_dados_parede
	call escreve_contadores_tela

	call waitchar	; espera usuario digitar enter para continuar
	call clrscr
	
	;	if ( setChar(FileHandleDst, DL) == 0) continue;
	mov		bx,FileHandleDst
	call	escreveContadores
	jnc		TerminouArquivo

	;	printf ("Erro na escrita....;)")
	;	fclose(FileHandleSrc)
	;	fclose(FileHandleDst)
	;	exit(1)
	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	;.exit 1
	jmp Inicio
	
	;} while(1);

TerminouArquivo:
	;fclose(FileHandleDst)
	;exit(0)
	mov		bx,FileHandleDst	; Fecha arquivo destino
	call	fclose
	jmp inicio 
	;.exit	0


 tam_quadrado proc near
	mov dx,0 ; divide 624 pela coluna
	mov ax,624
	div coluna  
	mov bx,ax 
 
	mov dx,0 ; divide 360 pela linha
	mov ax,360
	div linha

	cmp ax,bx ; coloca o menor em lado_quadrado
	jb colocaAX
	mov ax,bx

colocaAX:	
	mov lado_quadrado,ax 

	ret 
 tam_quadrado endp

		
;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de origem salva-o em FileNameSrc(copiado do moodle)
;--------------------------------------------------------------------
GetFileNameSrc	proc	near
	;printf("Nome do arquivo origem: ")
	lea		bx, MsgPedeArquivoSrc
	call	printf_s

	;gets(FileNameSrc);
	lea		bx, FileNameSrc
	call	gets

	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameSrc	endp


;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst(funcao adaptada do moodle)
;--------------------------------------------------------------------
GetFileNameDst	proc	near

	;gets(FileNameDst);
	lea		bx, FileNameDst


	lea		si,FileNameSrc					; Copia do buffer de teclado para o FileName
	mov 	di,bx
	mov		cl,String+1
	mov		ch,0
	rep 	movsb

	; agora coloca a extensao .rel
	std ; para voltar na string
	dec di ; para voltar para dentro da string
	mov		cl,String+1
	mov		ch,0
	mov 	al,'.'
	repne 	scasb

	cld ; retorna ao valor de antes
	inc di ; para ficar em '.'

	mov		byte ptr es:[di],'.'	
	inc		di
	mov		byte ptr es:[di],'r'
	inc		di	
	mov		byte ptr es:[di],'e'	
	inc		di
	mov		byte ptr es:[di],'l'	
	inc		di

	
	mov		byte ptr es:[di],0			; Coloca marca de fim de string

	ret
GetFileNameDst	endp


; em cx o numero de caracteres
; bx endereco da string
setString	proc	near
	mov 	dx,bx 
	mov 	bx,FileHandleDst
	mov		ah,40h
	int		21h
	ret
setString	endp	

;
;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX(adaptada de funcao no moodle)
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; Lê uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	pop 	bx

	mov 	ponto,0					; inicializa ponto (booleano)
	lea		di,String+2				; inicializa registrador para percorrer	
	mov		cl,String+1				; inicializa contador
	mov		ch,0
	mov 	al,'.'						; caractere para buscar
	; testa se acha ponto
	repne 	scasb
	jne 	continuaGets0 ; se nao achou continua
	inc 	ponto ;coloca 1 no booleano

	continuaGets0:
	lea		si,String+2					; Copia do buffer de teclado para o FileName
	mov 	di,bx
	mov		cl,String+1
	mov		ch,0
	rep 	movsb

	cmp 	ponto,0
	jne 	coloca0

	;incrementa numero de caracteres
	add 	string+1,4

	; coloca .par 
	mov		byte ptr es:[di],'.'	
	inc		di
	mov		byte ptr es:[di],'p'
	inc		di	
	mov		byte ptr es:[di],'a'	
	inc		di
	mov		byte ptr es:[di],'r'	
	inc		di

	coloca0:
	mov		byte ptr es:[di],0			; Coloca marca de fim de string


	ret
gets	endp


;Limpa tela e troca par ao modo texto
clrscr proc near
	; troca para o modo texto
	mov ah,0
	mov al,07h
	int 10h

	; limpa tela
    mov ax,0700h
    mov bh,07h 
    mov cx,0000h 
    mov dx,184fh 
    int 10h

	ret 
clrscr endp

;coloca o cursor na posicao
;DL=X, DH=Y.
set_cursor proc
      mov  ah, 2
      mov  bh, 0
      int  10h
      ret
set_cursor endp

;procedimento para zerar contadores
limpa_contadores proc
	lea di,contadores
	mov cx,16
	mov ax,0
	rep stosw
	ret
limpa_contadores endp

; informacao da parede em al
incrementaContador proc near 

	mov desenhar,0; reseta booleano

	cmp dl,'0'; verifica se caractere eh numero
	jb fimic
	cmp dl,'9'
	ja ic0

	sub dl,'0'
	inc desenhar 

	mov bl,dl	; incrementa contador
	mov bh,0
	add bx,bx
	add WORD ptr [bx+contadores],1

	jmp fimic

ic0:
	cmp dl,'A' ; verifica se eh letra vlida
	jb fimic
	cmp dl,'E'
	ja fimic

	sub dl,'A'-10
	inc desenhar 

	mov bl,dl ; incrementa contador
	mov bh,0
	add bx,bx
	add WORD ptr [bx+contadores],1

fimic:
	mov cor_atual,0
	mov cor_atual,dl
	ret 

incrementaContador endp 

; escreve contadores handle em bx
escreveContadores proc near
	mov		contAtual,0

	lea 	bx,Preto
	mov 	cx,tPreto
	call 	printf_f
	jnc		ec0
	ret
ec0:
	lea 	bx,Azul 
	mov 	cx,tAzul
	call 	printf_f
	jnc		ec1
	ret
ec1:
	lea 	bx,Verde 
	mov 	cx,tVerde
	call 	printf_f
	jnc		ec2
	ret
ec2:
	lea 	bx,Ciano 
	mov 	cx,tCiano
	call 	printf_f
	jnc		ec3
	ret
ec3:
	lea 	bx,Vermelho
	mov 	cx,tVermelho
	call 	printf_f
	jnc		ec4
	ret
ec4:
	lea 	bx,Magenta
	mov 	cx,tMagenta
	call 	printf_f
	jnc		ec5
	ret
ec5:
	lea 	bx,Marrom
	mov 	cx,tMarrom
	call 	printf_f
	jnc		ec6
	ret
ec6:
	lea 	bx,Cinza_claro
	mov 	cx,tCinza_escuro
	call 	printf_f
	jnc		ec7
	ret
ec7:
	lea 	bx,Cinza_escuro
	mov 	cx,tCinza_escuro
	call 	printf_f
	jnc		ec8
	ret
ec8:
	lea 	bx,Azul_claro
	mov 	cx,tAzul_claro
	call 	printf_f
	jnc		ec9
	ret
ec9:
	lea 	bx,Verde_claro
	mov 	cx,tVerde_claro
	call 	printf_f
	jnc		ec10
	ret
ec10:
	lea 	bx,Ciano_claro
	mov 	cx,tCiano_claro
	call 	printf_f
	jnc		ec11
	ret
ec11:
	lea 	bx,Vermelho_claro
	mov 	cx,tVermelho_claro
	call 	printf_f
	jnc		ec12
	ret
ec12:
	lea 	bx,Magenta_claro
	mov 	cx,tMagenta_claro
	call 	printf_f
	jnc		ec13
	ret
ec13:
	lea 	bx,Amarelo 
	mov 	cx,tamarelo
	call 	printf_f
	ret 



escreveContadores endp

; recebe em bx endereco da string
printf_f proc near

	call	setString
	jc		fimPrint_f

	call 	escreveContador
	jc 		fimPrint_f
	inc 	contAtual

	lea 	bx,MsgCRLF	
	mov 	cx,2
	call	setString

fimPrint_f:
	ret 

printf_f endp 


escreveContador proc near
	lea 	bx,contadores 
	add 	bx,contAtual
	add 	bx,contAtual
	mov		ax,[bx]

	lea 	bx,string_contador
	call 	sprintf_w
	lea		bx,string_contador
	call 	fprintf_s
	ret
escreveContador endp 


;--------------------------------------------------------------------
;Função: Escrever um string em arquivo
; 	recebe em bx o endereco da string
;--------------------------------------------------------------------

fprintf_s	proc	near

;	While (*s!='\0') {
	mov		dl,[bx]
	cmp		dl,0
	je		ps_11

;		putchar(*s)
	push	bx
	mov 	bx,FileHandleDst
	call 	setChar
	pop		bx
	jc		ps_11 


;		++s;
	inc		bx
		
;	}
	jmp		fprintf_s
		
ps_11:
	ret
	
fprintf_s	endp

; so esperar
waitchar proc near
	mov		ah,8
	int		21H
	ret
waitchar endp

; recebe em cx colunaa do pixel
; recebe em dx linha do pixel
escreve_pixel proc near
	mov ah,0ch
	mov bh,00h 
	int 10h
escreve_pixel endp

	;mov dx,396     ;top edge
    ;mov di,640      ;control y loop

	;mov cx,0     ;left edge
    ;mov si,640       ;control x loop
	;call linha_horizontal
escreve_dados_parede proc near
	mov  dl, 0                 ;◄■■ SCREEN COLUMN 0 (X).
	mov  dh, 25                 ;◄■■ SCREEN ROW 0 (Y).
	call set_cursor

	lea		bx,MSGarquivo
	call	printf_s

	lea		bx,FileNameSrc
	call	printf_s

	lea		bx,MSGarquivo2
	call	printf_s

	ret
escreve_dados_parede endp


escreve_contadores_tela proc near

	mov cor_atual,0
	mov x_atual,30
	mov y_atual,420 
	mov pos_x_contador,4
	mov pos_y_contador,28

loop_escreve_contadores_tela:

	call rejunte
	call DrawSquare

	mov 	al,cor_atual 
	mov 	ah,0
	lea 	bx,contadores 
	add 	bx,ax 
	add 	bx,ax 
	mov		ax,[bx]

	lea 	bx,string_contador
	call 	sprintf_w
	

	mov  dl, pos_x_contador                 ;◄■■ SCREEN COLUMN 0 (X).
	mov  dh, pos_y_contador     ;◄■■ SCREEN ROW 0 (Y).
	call set_cursor
	lea		bx,string_contador
	call	printf_s

	add pos_x_contador,5
	add x_atual,40
	add cor_atual,1 
	mov al,cor_atual
	cmp al,0fh
	jne loop_escreve_contadores_tela

	ret 
escreve_contadores_tela endp 

; desenha caixa 
desenha_caixa proc near
	mov cor_caixa,0eh


	mov dx,16   
	mov cx,0      
    mov si,640      
	call linha_horizontal


	mov dx,16     
    mov di,380     
	mov cx,0         
	call linha_vertical

	mov dx,396        
	mov cx,0    
    mov si,640       
	call linha_horizontal

	mov dx,16     
    mov di,380     
	mov cx,639             
	call linha_vertical

	ret 

desenha_caixa endp

; em desenhar tem booleano e em lado_quadrado o tam do lado
; I-----
; |
; |
desenha_quadrado proc near
	cmp desenhar,0	; verifica se pode senhar
	je fim_desenha_quadrado

	mov bx,coluna	; verifica se chegou no fim da linha
	cmp quadrado_pos,bx
	jne continua_desenha_quadrado
	
	mov quadrado_pos,0	; caso tenha chegado no fim da linha
	mov x_atual,pos_inicial_x
	mov bx,lado_quadrado
	add y_atual,bx

continua_desenha_quadrado:
	inc quadrado_pos 

	call desenha_rejunte	; desenha quadrado
	call interior_quadrado


	mov bx,lado_quadrado
	add x_atual,bx 

fim_desenha_quadrado:
	ret 
desenha_quadrado endp

; recebe em cx colunaa do pixel
; recebe em dx linha do pixel
; I
; |
; |
linha_vertical proc near

linha_vertical_loop:

    mov bh,0h                   ;video page
	mov al,cor_caixa
    mov ah,0ch                  ;draw pixel function
    int 10h                     ;BIOS video interrupt

    inc dx                      ;advance X position
    dec di                      ;count side of square to control the loop
    jne linha_vertical_loop            ;next horizontal pixel

	ret 
linha_vertical endp

; recebe em cx coluna do pixel
; recebe em dx linha do pixel
; I----
linha_horizontal proc near
linha_horizontal_loop:

    mov bh,0h                   ;video page
	mov al,cor_caixa
    mov ah,0ch                  ;draw pixel function
    int 10h                     ;BIOS video interrupt

    inc cx                      ;advance X position
    dec si                      ;count side of square to control the loop
    jne linha_horizontal_loop           ;next horizontal pixel

	ret 
linha_horizontal endp



rejunte proc near
    ;mov dx,[Player1Drawy]       ;top edge
    ;mov di,[SideLength]         ;control y loop
	mov dx,y_atual      ;top edge
    mov di,lado_quadrado        ;control y loop
    ;mov di,14h                  ;or this, if the side length is fixed

SquareYlooprejunte:
    ;mov cx,[Player1Drawx]       ;left edge
    ;mov si,[SideLength]         ;control x loop
	mov cx,x_atual      ;left edge
    mov si,lado_quadrado        ;control x loop
    ;mov si,14h                  ;or this, if the side length is fixed

SquareXlooprejunte:
    push cx                     ;I don't know if these 4 pushes are necessary...
    push dx
    push si
    push di

    mov bh,0h                   ;video page
    ;mov al,[player1disccolor]   ;colour
	mov al,0fh
    mov ah,0ch                  ;draw pixel function
    int 10h                     ;BIOS video interrupt

    pop di                      ;... or these 4 matching pops are necessary
    pop si                      ;depends on whether int 10h func corrupts them
    pop dx
    pop cx

    inc cx                      ;advance X position
    dec si                      ;count side of square to control the loop
    jne SquareXlooprejunte             ;next horizontal pixel

    inc dx                      ;advance Y position
    dec di                      ;count side of square to control the loop
    jne SquareYlooprejunte            ;next row

	ret 
rejunte endp


; desenha rejunte
desenha_rejunte proc near
	mov cor_caixa,0fh

	mov dx,y_atual
	mov cx,x_atual         
    mov si,lado_quadrado      
	call linha_horizontal


	mov dx,y_atual    
    mov di,lado_quadrado     
	mov cx,x_atual           
	call linha_vertical

	mov dx,y_atual
	add dx,lado_quadrado
	sub dx,1       
	mov cx,x_atual  
    mov si,lado_quadrado       
	call linha_horizontal

	mov dx,y_atual     
    mov di,lado_quadrado    
	mov cx,x_atual             
	add cx,lado_quadrado
	sub cx,1  
	call linha_vertical

	ret 

desenha_rejunte endp




interior_quadrado proc near
	mov dx,y_atual      ;top edge
	add dx,1
    mov di,lado_quadrado        ;control y loop
	sub di,2

SquareYloop:
	mov cx,x_atual      ;left edge
	add cx,1
    mov si,lado_quadrado        ;control x loop
	sub si,2

SquareXloop:
    push cx                     ;I don't know if these 4 pushes are necessary...
    push dx
    push si
    push di

    mov bh,0h                   ;video page
    ;mov al,[player1disccolor]   ;colour
	mov al,cor_atual
    mov ah,0ch                  ;draw pixel function
    int 10h                     ;BIOS video interrupt

    pop di                      ;... or these 4 matching pops are necessary
    pop si                      ;depends on whether int 10h func corrupts them
    pop dx
    pop cx

    inc cx                      ;advance X position
    dec si                      ;count side of square to control the loop
    jne SquareXloop             ;next horizontal pixel

    inc dx                      ;advance Y position
    dec di                      ;count side of square to control the loop
    jne SquareYloop             ;next row

	ret 
interior_quadrado endp



;--------------------------------------------------------------------
;Função:Converte um ASCII-DECIMAL para HEXA(copiada do moodle)
;Entra: (S) -> DS:BX -> Ponteiro para o string de origem
;Sai:	(A) -> AX -> Valor "Hex" resultante
;Algoritmo:
;	A = 0;
;	while (*S!='\0') {
;		A = 10 * A + (*S - '0')
;		++S;
;	}
;	return
;--------------------------------------------------------------------
atoi	proc near

		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		ret

atoi	endp


;--------------------------------------------------------------------
;Função: Converte um inteiro (n) para (string)(copiada do moodle)
;		 sprintf(string, "%d", n)
;
;void sprintf_w(char *string->BX, WORD n->AX) {
;	k=5;
;	m=10000;
;	f=0;
;	do {
;		quociente = n / m : resto = n % m;	// Usar instrução DIV
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
;		n = resto;
;		m = m/10;
;		--k;
;	} while(k);
;
;	if (!f)
;		*string++ = '0';
;	*string = '\0';
;}
;
;Associação de variaveis com registradores e memória
;	string	-> bx
;	k		-> cx
;	m		-> sw_m dw
;	f		-> sw_f db
;	n		-> sw_n	dw
;--------------------------------------------------------------------

sprintf_w	proc	near

;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instrução DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
	ret
		
sprintf_w	endp





;--------------------------------------------------------------------
;Função Escrever um string na tela (copiada dos arquivos no moodle)
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		printf_s_fim

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
printf_s_fim:
	ret
printf_s	endp



;--------------------------------------------------------------------
;Função	Abre o arquivo cujo nome está no string apontado por DX(funcao do moodle)
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Função Cria o arquivo cujo nome está no string apontado por DX(funcao copiada do moodle)
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle(funcao copiada do moodle)
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Função	Le um caractere do arquivo identificado pelo HANLDE BX(copiado do moodle)
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp
		
;--------------------------------------------------------------------
;Entra: BX -> file handle (copiada do moodle)
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------