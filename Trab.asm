
;
;====================================================================
;	- Escrever um programa para ler um arquivo texto e 
;		apresentá-lo na tela
;	- O usuário devem informar o nome do arquivo, 
;		assim que for apresentada a mensagem: “Nome do arquivo: “
;====================================================================
;
	.model		small
	.stack
		
CR		equ		0dh
LF		equ		0ah

	.data
FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleSrc	dw		0				; Handler do arquivo origem
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo

MsgInicio db "Aluno: Gabriel Couto Domingues Matricula: 302229", CR, LF, 0 
MsgFim db "Programa Encerrado", CR, LF, 0 

MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF				db	CR, LF, 0

MAXSTRING	equ		200
String	db		MAXSTRING dup (?)		; Usado na funcao gets
Ponto db 0 ; para saber se tem ponto a string de entrada

Contadores dw 16 dup(?); contadores da parede

; variaveis para converter numero para string
string_contador db	10 dup (?)
H2D		db	10 dup (?)
sw_n	dw	0
sw_f	db	0
sw_m	dw	0

ContAtual dw 0 

; informacoes da parede
string_linha db 0,0,0

string_coluna db 0,0,0

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


Desenhar dw 0;booleano para saber se tem que desenhar

	.code
	.startup

	
Inicio:
	;limpa tela
	call clrscr

	;limpa dimensoes
	mov string_linha,0
	mov string_linha+1,0
	mov string_coluna,0
	mov string_coluna+1,0

	;coloca es = ds
	mov	 	bx,ds
	mov 	es,bx

	;direcao
	cld

	;cursor no inicio
	mov  dl, 0                 ;◄■■ SCREEN COLUMN 0 (X).
	mov  dh, 0                 ;◄■■ SCREEN ROW 0 (Y).
	call set_cursor             ;◄■■ SET CURSOR POSITION.

	;zera contadores
	call limpa_contadores

	;Mensagem de inicio
	lea		bx,MsgInicio
	call	printf_s

	;GetFileNameSrc();	// Pega o nome do arquivo de origem -> FileNameSrc
	call	GetFileNameSrc


	cmp string+1,0
	jne continua0

	; so foi digitado enter
	lea		bx,MsgFim
	call	printf_s
	.exit 0 


continua0:
	;if (fopen(FileNameSrc)) {
	;	printf("Erro na abertura do arquivo.\r\n")
	;	exit(1)
	;}
	;FileHandleSrc = BX
	lea		dx,FileNameSrc
	call	fopen
	mov		FileHandleSrc,bx
	jnc		le_dimensao 
	lea		bx, MsgErroOpenFile
	call	printf_s
	;.exit	1
	jmp inicio 

le_dimensao:
	mov		bx,FileHandleSrc
	call	getChar
	jc		erro_dimensao
	mov 	string_linha,dl

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
	call	getChar
	jc		erro_dimensao
	mov 	string_coluna,dl

	call	getChar
	jc		erro_dimensao
	cmp 	dl,' '
	je		guarda_dimensao
	cmp 	dl,CR
	je		guarda_dimensao

	mov 	string_coluna+1,dl
	jmp 	guarda_dimensao

	erro_dimensao:
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc
	call	fclose
	;.exit	1
	jmp inicio

guarda_dimensao:
	lea bx,string_linha 
	call atoi 
	mov linha,ax

	lea bx,string_coluna  
	call atoi
	mov coluna,ax
Continua1:

	;do {
	;	if ( (CF,DL,AX = getChar(FileHandleSrc)) ) {
	;		printf("");
	;		fclose(FileHandleSrc)
	;		fclose(FileHandleDst)
	;		exit(1)
	;	}
	mov		bx,FileHandleSrc
	call	getChar
	jnc		Continua2
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc
	call	fclose
	;.exit	1
	jmp Inicio
Continua2:

	;	if (AX==0) break;
	cmp		ax,0
	jz		continua3
	
	call 	incrementaContador
	; desenhar ladrilhos vai aqui 
	; desenhar ladrilhos vai aqui 
	; desenhar ladrilhos vai aqui 
	; desenhar ladrilhos vai aqui 
	; desenhar ladrilhos vai aqui 
	; desenhar ladrilhos vai aqui 
	jmp 	continua1
Continua3:
	; fecha arquivo com as paredes
	mov		bx,FileHandleSrc
	call	fclose


	;GetFileNameDst();	// Pega o nome do arquivo de origem -> FileNameDst
	call	GetFileNameDst

	;if (fcreate(FileNameDst)) {
	;	fclose(FileHandleSrc);
	;	printf("Erro na criacao do arquivo.\r\n")
	;	exit(1)
	;}
	;FileHandleDst = BX
	lea		dx,FileNameDst
	call	fcreate
	mov		FileHandleDst,bx
	jnc		Continua4
	lea		bx, MsgErroCreateFile
	call	printf_s
	;.exit	1
	jmp inicio

Continua4:
	
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


		
;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de origem salva-o em FileNameSrc
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
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst
;--------------------------------------------------------------------
GetFileNameDst	proc	near

	;gets(FileNameDst);
	lea		bx, FileNameDst


	lea		si,FileNameSrc					; Copia do buffer de teclado para o FileName
	mov 	di,bx
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	; agora coloca a extensao .rel
	dec		di
	dec		di
	dec		di
	dec		di

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

;--------------------------------------------------------------------
;Função	Abre o arquivo cujo nome está no string apontado por DX
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
;Função Cria o arquivo cujo nome está no string apontado por DX
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
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Função	Le um caractere do arquivo identificado pelo HANLDE BX
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
;Entra: BX -> file handle
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
;Funcao Le um string do teclado e coloca no buffer apontado por BX
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
	mov		ax,ds						; Ajusta ES=DS 
	mov		es,ax
	mov 	al,'.'						; caractere para buscar
	; testa se acha ponto
	repne 	scasb
	jne 	continuaGets0
	inc 	ponto 

	continuaGets0:
	lea		si,String+2					; Copia do buffer de teclado para o FileName
	mov 	di,bx
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
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


;--------------------------------------------------------------------
;Função Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

;Limpa tela
clrscr proc near
    mov ax,0700h  ; function 07, AL=0 means scroll whole window
    mov bh,07h    ; character attribute = white on black
    mov cx,0000h  ; row = 0, col = 0
    mov dx,184fh  ; row = 24 (0x18), col = 79 (0x4f)
    int 10h        ; call BIOS video interrupt

	ret 
clrscr endp

;coloca o cursor na posicao
;INPUT : DL=X, DH=Y.
set_cursor proc
      mov  ah, 2                  ;SERVICE TO SET CURSOR POSITION.
      mov  bh, 0                  ;VIDEO PAGE.
      int  10h                    ;BIOS SERVICES.
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
	mov desenhar,0

	cmp dl,'0'
	jb fimic
	cmp dl,'9'
	ja ic0

	sub dl,'0'
	inc desenhar 

	mov bl,dl
	mov bh,0
	add bx,bx
	add WORD ptr [bx+contadores],1

	jmp fimic

	ic0:
	cmp dl,'A'
	jb fimic
	cmp dl,'E'
	ja fimic

	sub dl,'A'-10
	inc desenhar 

	mov bl,dl
	mov bh,0
	add bx,bx
	add WORD ptr [bx+contadores],1

	fimic:
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
	call fprintf_s
	ret
escreveContador endp 


;--------------------------------------------------------------------
;Função:Converte um ASCII-DECIMAL para HEXA
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
;Função: Converte um inteiro (n) para (string)
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
	jmp		printf_s
		
ps_11:
	ret
	
fprintf_s	endp

; so esperar
waitchar proc near
	mov		ah,8
	int		21H
	ret
waitchar endp


;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------


	