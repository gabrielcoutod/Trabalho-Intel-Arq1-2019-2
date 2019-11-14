
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

linha dw 0
coluna dw 0 

Desenhar dw 0;booleano para saber se tem que desenhar

	.code
	.startup

	
Inicio:

	call clrscr

	;cursor no inicio
	mov  dl, 0                 ;◄■■ SCREEN COLUMN 18 (X).
	mov  dh, 0                 ;◄■■ SCREEN ROW 2 (Y).
	call set_cursor             ;◄■■ SET CURSOR POSITION.

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
	jnc		Continua1
	lea		bx, MsgErroOpenFile
	call	printf_s
	.exit	1
Continua1:

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
	jnc		Continua2
	mov		bx,FileHandleSrc
	call	fclose
	lea		bx, MsgErroCreateFile
	call	printf_s
	.exit	1
Continua2:

	;do {
	;	if ( (CF,DL,AX = getChar(FileHandleSrc)) ) {
	;		printf("");
	;		fclose(FileHandleSrc)
	;		fclose(FileHandleDst)
	;		exit(1)
	;	}
	mov		bx,FileHandleSrc
	call	getChar
	jnc		Continua3
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandleSrc
	call	fclose
	mov		bx,FileHandleDst
	call	fclose
	.exit	1
Continua3:

	;	if (AX==0) break;
	cmp		ax,0
	jz		TerminouArquivo
	
	call incrementaContador
Continua4:

	;	if ( setChar(FileHandleDst, DL) == 0) continue;
	mov		bx,FileHandleDst
	call	setChar
	jnc		Continua2

	;	printf ("Erro na escrita....;)")
	;	fclose(FileHandleSrc)
	;	fclose(FileHandleDst)
	;	exit(1)
	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandleSrc		; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	.exit	1
	
	;} while(1);
		
TerminouArquivo:
	;fclose(FileHandleSrc)
	;fclose(FileHandleDst)
	;exit(0)
	mov		bx,FileHandleSrc	; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst	; Fecha arquivo destino
	call	fclose
	.exit	0

		
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


clrscr proc near
;Limpa tela
    mov ax,0700h  ; function 07, AL=0 means scroll whole window
    mov bh,07h    ; character attribute = white on black
    mov cx,0000h  ; row = 0, col = 0
    mov dx,184fh  ; row = 24 (0x18), col = 79 (0x4f)
    int 10h        ; call BIOS video interrupt

	ret 
clrscr endp


;INPUT : DL=X, DH=Y.
set_cursor proc
      mov  ah, 2                  ;◄■■ SERVICE TO SET CURSOR POSITION.
      mov  bh, 0                  ;◄■■ VIDEO PAGE.
      int  10h                    ;◄■■ BIOS SERVICES.
      ret
set_cursor endp


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
	add WORD ptr [bx+contadores],1

	jmp fimic

	ic0:
	cmp dl,'a'
	jb fimic
	cmp dl,'e'
	ja fimic

	sub dl,'a'-10
	inc desenhar 

	mov bl,dl
	mov bh,0
	add WORD ptr [bx+contadores],1

	fimic:
	ret 

incrementaContador endp 


;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------


	