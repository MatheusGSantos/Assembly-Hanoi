.686
.model flat, stdcall

option casemap:none


include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

include \masm32\macros\macros.asm

.data
   msg_1 db "Mova o disco de",0
   msg_2 db " para o disco",0
   n_line db 10
   torre1 DWORD 1
   torre2 DWORD 2
   torre3 DWORD 3
   entrada db ?
   var_1 db ?
   var_2 db ?

   carac_lidos dd 0
   write_count dd 0
   contador dd 0
   numeros dd 126 dup(0)    ;; array de inteiros
   indice dd 0              ;; indice da próxima posição vazia
      
.code
 funcao_hanoi:
    push ebp
    mov ebp, esp

    ;; zerando os registradores
    xor ecx, ecx
    xor edi, edi
    xor ebx, ebx
    xor esi, esi
    xor eax, eax

    ;; mover parametro para registradores
    mov ecx, DWORD PTR[ebp+20]         ;; numero de discos
    mov edi, DWORD PTR[ebp+16]         ;; torre1 / origem
    mov ebx, DWORD PTR[ebp+12]         ;; torre3 / destino
    mov esi, DWORD PTR[ebp+8]          ;; torre2 / auxiliar

    comeco:
        cmp ecx, 1                      ;; verifica se o número de discos é igual a 1
            je label_um
            ja label_maior
        label_um:
            inc contador
            
            ;; guardar movimento
            mov eax, indice
            mov numeros[eax*4], edi     ;; salva origem
            inc eax
            mov numeros[eax*4], ebx     ;; salva destino
            inc eax
            mov indice, eax
            jmp rtrn
                
        label_maior:
            dec ecx                     ;; decrementa ecx

            ;; chamada recursiva 1
            push ecx                    ;; numero de discos - 1
            push edi                    ;; origem
            push esi                    ;; auxiliar
            push ebx                    ;; destino
            call funcao_hanoi           ;; chama a funcao novamente
            pop ebx                     ;; pop nos registradores
            pop esi
            pop edi
            pop ecx

            inc contador
            
            ;; guardar movimento
            mov eax, indice
            mov numeros[eax*4], edi     ;; salva origem
            inc eax
            mov numeros[eax*4], ebx     ;; salva destino
            inc eax
            mov indice, eax
        

            ;; chamada recursiva 2
            push ecx                    ;; numero de discos - 1
            push esi                    ;; auxiliar
            push ebx                    ;; destino
            push edi                    ;; origem
            call funcao_hanoi
            pop edi
            pop ebx
            pop esi
            pop ecx            
        rtrn:
            mov esp, ebp
            pop ebp
            ret

  


start:
    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr entrada, sizeof entrada, addr carac_lidos, NULL

    mov esi, OFFSET entrada ; Armazenar apontador da string em esi
        proximo:
            mov al, [esi] ; Mover caracter atual para al
            inc esi ; Apontar para o proximo caracter
            cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
            jl terminar
            cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
            jl proximo
        terminar:
            dec esi ; Apontar para caracter anterior
            xor al, al ; 0 ou NULL
            mov [esi], al ; Inserir NULL logo apos o termino do numero
    invoke atodw, addr entrada
    
    ;; chamada da funcao
    push eax
    push torre1
    push torre3
    push torre2
    call funcao_hanoi
    pop torre2
    pop torre3
    pop torre1
    pop eax
    dec indice     

    ;; empilhar movimentos
    push -1
    xor ecx, ecx
    
    empilhar:   
        mov ecx, indice                             ;; salvar indice em ecx
        cmp ecx, 0                                  ;; verifica se o indice é menor que 0
            jl desempilhar                                   
        xor edx, edx
        mov edx, numeros[ecx*4]
        push edx
        dec indice
        jmp empilhar
        
    desempilhar:
        loop_print:
            ;;call print_par
            xor ebx, ebx
            xor ecx, ecx
            pop ebx
            cmp ebx, -1
                je end_loop
            
            ;; print msg1
            push STD_OUTPUT_HANDLE
            call GetStdHandle
            invoke WriteConsole, eax, addr msg_1, sizeof msg_1, addr write_count, NULL

            ;; print origem
            invoke dwtoa, ebx, addr var_1
            push STD_OUTPUT_HANDLE
            call GetStdHandle
            invoke WriteConsole, eax, addr var_1, sizeof var_1, addr write_count, NULL


            ;; print msg2
            push STD_OUTPUT_HANDLE
            call GetStdHandle
            invoke WriteConsole, eax, addr msg_2, sizeof msg_2, addr write_count, NULL

            pop ecx
            ;; print destino
            invoke dwtoa, ecx, addr var_2
            push STD_OUTPUT_HANDLE
            call GetStdHandle
            invoke WriteConsole, eax, addr var_2, sizeof var_2, addr write_count, NULL

            ;; print \n
            push STD_OUTPUT_HANDLE
            call GetStdHandle
            invoke WriteConsole, eax, addr n_line, sizeof n_line, addr write_count, NULL

            jmp loop_print
            
        end_loop:
            invoke ExitProcess, 0    
  end start