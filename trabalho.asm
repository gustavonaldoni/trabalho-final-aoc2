# Este programa lê um arquivo até os 256 primeiros bytes (caracteres)
# O arquivo deve estar na pasta de instalação do Mars caso não seja
# indicado o caminho completo 
#
.data  
arquivo: .asciiz "Trabalho\\arquivo.txt"      # nome do arquivo
buffer: .space 256
paridade: .asciiz "   Paridade: "
fcs: .asciiz "Resultado FCS: "
mask: .word 0x40        
           

.text
# $s0: descritor do arquivo aberto
# $s1: endereço do bloco de dados do arquivo lido
#abre arquivo para leitura
	li   $v0, 13       		# chamada de sistema para abrir arquivo
	la   $a0, arquivo      
	li   $a1, 0        		# abrir para leitura
	li   $a2, 0
	syscall            		# abre arquivo! (descritor do arquivo retornado em $v0)
	move $s0, $v0      		# salva o descritor de arquivo

#lê do arquivo
	li   $v0, 14       		# chamada de sistema para ler arquivo
	move $a0, $s0      		# descritor do arquivo 
	la   $a1, buffer   		# endereço do buffer para receber a leitura
	move $s1, $a1      		# salva ponteiro para buffer em $s1
	li   $a2, 256     		# número máximo de caracters a serem lidos
	syscall            		# executa leitura do arquivo!

# Fecha o arquivo 
	li   $v0, 16       		# chamada de sistema para fechar arquivo
	move $a0, $s0      		# descritor do arquivo a ser fechado
	syscall   	    		# fecha arquivo!
	       
# imprime conteúdo do buffer    
        add  $t0, $zero, $zero   	# i = 0
    	add  $t1, $s1, $t0
    	lb   $s3, 0($t1) 		#primeiro caracter
    	lb   $s4, 1($t1)                #segundo caracter
    	xor $s3, $s3, $s4 	        #xor entre eles
	addi $t1, $t1, 2		#soma o contador
	   
    	L1:	
    	lb   $s4, 0($t1) 		#comeca com o terceiro caracter e compara com o segundo
     	xor $s3, $s3, $s4		
    	beq  $t0, 256, out  		#quando chega em 256 caracteres acaba
        addi $t0, $t0, 1         	#soma contador
        addi $t1, $t1, 1         	#soma endereço
        j L1                  		#volta para o loop
    	out:
    	jal  imprimeFCS 
        j imprimeParidade

	imprimeFCS:	
	li $v0, 4
    	la $a0, fcs
    	syscall
	
	li $v0, 35	# imprime $s3
	move $a0, $s3
	syscall
	jr $ra
	
	imprimeParidade:
	li $v0, 11
    	li $a0, '\n'
    	syscall
    	
    	add  $t0, $zero, $zero
    	add  $t1, $s1, $t0

	volta:
	beq $t8, 256, fim
	
        add  $t0, $zero, $zero
	add  $t6, $zero, $zero
        lw $t3, mask
        lb $s3, 0($t1)
        
    	L2:    	
    	beq $t0, 7, resultado 		#testa se leu todos
    	and $s5, $s3, $t3
    			
    	bne $s5, $zero, soma 	
    	srl $t3, $t3, 1
    	addi $t0, $t0, 1
    	j L2
    	
    	soma:
    	srl $t3, $t3, 1
    	addi $t0, $t0, 1
    	addi $t6, $t6, 1
    	j L2
    	
    	resultado:		
 	li $t7, 2
 	div $t6, $t7
 	mfhi $t6
 			
	li $v0, 35
	move $a0, $s3
	syscall
	
	li $v0, 4
        la $a0, paridade
        syscall
        
        li $v0, 1
        move $a0, $t6
        syscall
        
        li $v0, 11
    	li $a0, '\n'
    	syscall
        
        addi $t1, $t1, 1
        addi $t8, $t8, 1
        j volta
        
        fim:
        li $v0, 10
        syscall
