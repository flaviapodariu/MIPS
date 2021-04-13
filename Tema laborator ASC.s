.data
matrice   : .space 1600
space     : .asciiz " "
newLine   : .asciiz "\n"
roles     : .space 80
badSwitch : .asciiz "switch malitios index "
controller: .asciiz "controller index "
host      : .asciiz "host index "
goodSwitch: .asciiz "switch index "
pctVirg   : .asciiz "; "
douaPct   : .asciiz ": "
cod1      : .word 1
cod2      : .word 2
cod4      : .word 4
visited   : .space 80
queue     : .space 80
yes       : .asciiz "\nYes"
no        : .asciiz "\nNo"
mesaj     : .space 30
literaj   : .word 106  # j
literaa   : .word 97   # a
literaz   : .word 122  # z
zece      : .word 10
.text
main:                  
li       $v0, 5              #citesc nr noduri -> $s0
syscall  
move     $s0, $v0
mul      $t8, $s0, $s0       # t8 -> nr total elem matrice

li       $v0, 5              #citesc nr muchii -> $t6
syscall
move     $t6, $v0


li   $t0, 0              # $t0 -> contor de elemente 
li   $t1, 0              # $t1 -> contor de accesare element (merge din 4 in 4)

init_Matrice:
    bge     $t0, $t8, gata
    addi    $t2, $zero, 0
    sw      $t2, matrice($t1)
    addi    $t0, $t0, 1
    addi    $t1, $t1, 4
    j init_Matrice

gata:

addi $t4, $zero, 1
addi $t0, $zero, 1

reprezentare_legaturi:
    bgt $t0, $t6, legaturi_reprezentate

    li      $v0, 5
    syscall
    move    $t1, $v0    
    move    $t3, $t1           # in t3 retin o copie a lui t1

    li      $v0, 5
    syscall
    move    $t2, $v0           # daca t1 si t2 sunt nodurile conectate atunci M[t1][t2] = 1

    mul     $t1, $t1, $s0      # t1 * nr noduri(s0) --> linia pe care trb sa ajung
    add     $t1, $t1, $t2      # coloana pe care trb sa ajung
    sll     $t1, $t1, 2        # shift left -> inmultesc t1 cu 2^2 ca sa devina index valid
    sw      $t4, matrice($t1)  # pun 1 in matrice la indexul unde am legatura, apoi repet procesul si invers pt ca graful este neorientat

    mul     $t2, $t2, $s0
    add     $t2, $t2, $t3      #folosesc t3 in loc de t1 pt ca t1 a fost modificat mai devreme
    sll     $t2, $t2, 2
    sw      $t4, matrice($t2)

    addi    $t0, $t0, 1
    j reprezentare_legaturi

legaturi_reprezentate:

addi $t0, $zero, 0
addi $t1, $zero, 0
addi $t2, $zero, 0            
addi $t3, $zero, 0
addi $t4, $zero, 0

citire_roles:
    bge     $t0, $s0, roles_citit
    
    li      $v0, 5
    syscall
    sw      $v0, roles($t1)

    addi    $t0, $t0, 1
    addi    $t1, $t1, 4

    j citire_roles
roles_citit:

addi $t3, $zero, 1       #variabila cu care dau newline la afisare

###############################################################################################################################################################

li $v0, 5
syscall                        # citesc codul cerintei (1, 2 sau 3)
move $t0, $v0

addi $t1, $zero, 1
addi $t2, $zero, 2
addi $t3, $zero, 3

beq $t0, $t1, cerinta1
beq $t0, $t2, cerinta2
beq $t0, $t3, cerinta3

####################################-NOTA 5-###########################################################################################################################

cerinta1:
addi $t0, $zero, 0             # $t0 -> index normal pt roles (+1)
addi $t2, $zero, 0             # am terminat cu codul cerintei, golesc toti registrii utilizati pt asta
addi $t1, $zero, 0             # $t1 -> index pt accesare elem (+4)
addi $t3, $zero, 3             # 3 = codul unui switch malitios

verificare_switch_malitios:
    bge    $t0, $s0, am_luat_nota5

    addi   $t7, $zero, 0     #pregatesc contorul pt cautare legaturi de acum
    addi   $t9, $zero, 0     #contor pt inaintare pe linie 

    lw     $t2, roles($t1)
     
    beq    $t2, $t3, afisare_bad_switch 

    continuare_verificare_switch:
    
    addi   $t0, $t0, 1
    addi   $t1, $t1, 4
    j verificare_switch_malitios


afisare_bad_switch:
    addi   $s3, $zero, 0
    li     $v0, 4
    la     $a0, badSwitch
    syscall

    li     $v0, 1
    move   $a0, $t0
    syscall
    
    li     $v0, 4  
    la     $a0, douaPct
    syscall

    j cautare_legaturi


cautare_legaturi:
    
    bge    $t7, $s0, EOL

    mul    $t4, $t0, $s0          # t4 = a[0][linie switch malitios]
    sll    $t4, $t4, 2            # locatia in memorie a lui a[0][linie switch malitios]
    add    $t4, $t4, $t9 
    lw     $t8, matrice($t4)   

    bne    $t8, $zero, afisari_echipamente

    cautare_echipamente_infectate_continuare:

    addi   $t9, $t9, 4
    addi   $t7, $t7, 1

    j cautare_legaturi


afisari_echipamente:
    lw     $t5, roles($t9)             # t5 contine tipul echipamentului infectat
    lw     $s1, cod1                   # pun codurile in registrii ca sa stiu ce afisez
    lw     $s2, cod2
    lw     $s4, cod4

    srl    $t9, $t9, 2            

    beq    $t5, $s1, host_infectat
    beq    $t5, $s2, switch_infectat
    beq    $t5, $s4, controller_infectat


host_infectat:
    bne    $s3, $zero, pune_pct_virgula
    inapoi_la_host:
    li     $v0, 4
    la     $a0, host
    syscall

    li     $v0, 1
    move   $a0, $t9
    syscall

    sll    $t9, $t9, 2
    addi   $s3, $zero, 1               # s3 = 1 --> de acum pun ; pana ajung la alt switch malitios 

    j cautare_echipamente_infectate_continuare


switch_infectat:
    bne    $s3, $zero, pune_pct_virgula
    inapoi_la_switch:
    li     $v0, 4
    la     $a0, goodSwitch
    syscall

    li     $v0, 1
    move   $a0, $t9
    syscall

    sll    $t9, $t9, 2
    addi   $s3, $zero, 1               # s3 = 1 --> de acum pun ; pana ajung la alt switch malitios 

    j cautare_echipamente_infectate_continuare


controller_infectat:
    bne    $s3, $zero, pune_pct_virgula
    inapoi_la_controller:
    li     $v0, 4
    la     $a0, controller
    syscall

    li     $v0, 1
    move   $a0, $t9
    syscall

    sll    $t9, $t9, 2
    addi   $s3, $zero, 1               # s3 = 1 --> de acum pun ; pana ajung la alt switch malitios 

    j cautare_echipamente_infectate_continuare

pune_pct_virgula:
    li     $v0, 4
    la     $a0, pctVirg
    syscall

    beq    $t5, $s1, inapoi_la_host
    beq    $t5, $s2, inapoi_la_switch
    beq    $t5, $s4, inapoi_la_controller

EOL:
   li $v0, 4
   la $a0, pctVirg
   syscall
   li $v0, 4
   la $a0, newLine
   syscall
   j continuare_verificare_switch

####################################-NOTA 7-###########################################################################################
  cerinta2:
    sll       $s1, $s0, 2
    addi      $t0, $zero, 0
    addi      $t1, $zero, 0
      initializare_visited:
         bge  $t0, $s1, visited_gata
         sw   $t1, visited($t0)
         addi $t0, $t0, 4
          j initializare_visited

      visited_gata:
      
      addi    $t0, $zero, 0       # $t0 = q LENGTH 
      addi    $t1, $zero, 0       # $t1 = q INDEX
      addi    $t2, $zero, 0       # $t2 = current node
      addi    $t3, $zero, 0

      sw      $zero, queue($t0)     # incep coada de la nodul 0
      addi    $t0, $t0, 4 

      lw      $t3, cod1           # cu t3 verific daca nodul e host sau daca nodul e vizitat
      sw      $t3, visited($t2)

    adaugare_nod_curent:
      beq     $t1, $t0, yes_or_no
      lw      $t2, queue($t1)         #nod curent = q[q index]   
      addi    $t1, $t1, 4             # q index + 1 
      sll     $t2, $t2, 2             #nod curent = poz nod curent

      lw      $t4, roles($t2)

      beq     $t4, $t3, hostFound     #daca am gasit host, il afisez
      cautare_host_continuare:
      addi    $t5, $zero, 0           # t5 = coloana 
    
      adugare_vecini_in_q:
            bge    $t5, $s1, vecini_adaugati   
            mul    $t7, $t2, $s0              # $t7 = adresa liniei nodului curent
            add    $t7, $t7, $t5              # $t7 = matrice[nodCurent][coloana]
            lw     $t9, matrice($t7)

            beq   $t9, $t3, verificare_vecin
            
            vecin_verificat:
            addi   $t5, $t5, 4
            

            j adugare_vecini_in_q

      vecini_adaugati:
           
      j adaugare_nod_curent



verificare_vecin:
     lw   $s3, visited($t5)
     bne  $s3, $t3, verificare_vizitat
     j vecin_verificat

verificare_vizitat:
     srl  $t5, $t5, 2
     sw   $t5, queue($t0)
     sll  $t5, $t5, 2
     addi $t0, $t0, 4
     sw   $t3, visited($t5)

     j vecin_verificat

hostFound:
li      $v0, 4
la      $a0, host
syscall

srl     $t2, $t2, 2  #impart t2 la 4 ca sa afisez indexul normal

li      $v0, 1
move    $a0, $t2 
syscall

sll     $t2, $t2, 2  #readuc t2 la forma initiala (multiplu de 4)

li      $v0, 4
la      $a0, pctVirg
syscall

j cautare_host_continuare

yes_or_no:
   beq $t0, $s1, printYES
   bne $t0, $s1, printNO
     

printYES:
li $v0, 4
la $a0, yes
syscall
j am_luat_nota7

printNO:
li $v0, 4
la $a0, no
syscall
j am_luat_nota7

am_luat_nota5:
li $v0, 10
syscall

am_luat_nota7:
li $v0, 10
syscall

############################-NOTA 10-######################################################################                             
# -> aplic bfs dar ignor toate switch-urile malitioase. Daca host-ul destinatie                           #
#    nu mai este vizitat => singurul path valid era cel care continea switch-ul malitios => decriptez     #
#    mesajul initial (deplasare -10). Altfel, afisez mesajul din input nemodificat.                       #
###########################################################################################################
cerinta3:
    li      $v0, 5
    syscall
    move    $s4, $v0     #host de la care incep 

    li      $v0, 5
    syscall
    move    $s5, $v0     #host la care trebuie sa ajung

    li      $v0, 8
    la      $a0, mesaj
    syscall
    
    sll       $s1, $s0, 2
    addi      $t0, $zero, 0
    addi      $t1, $zero, 0
initializare_visited1:
         bge  $t0, $s1, visited_gata1
         sw   $zero, visited($t0)
         addi $t0, $t0, 4
         j initializare_visited1

      visited_gata1:

      addi    $t0, $zero, 0      
      addi    $t1, $zero, 0       
      addi    $t2, $zero, 0       
      addi    $t3, $zero, 0
   

      sw      $s4, queue($zero)     # incep coada de la nodul s4(input)
      addi    $t0, $t0, 4 
      sll     $s4, $s4, 2
      lw      $t3, cod1           
      sw      $t3, visited($s4)
      addi    $s6, $zero, 3               #cod sw malitios
      srl     $s4, $s4, 2
 adaugare_nod_curent1:
      beq     $t1, $t0, verificare_host_input
      lw      $t2, queue($t1)         #nod curent = q[q index]   
   
      addi    $t1, $t1, 4             # q index + 1 
      sll     $t2, $t2, 2             # t2 ia forma de index
      lw      $t4, roles($t2)
   
      addi    $t5, $zero, 0                # t5 = coloana 
      
      adugare_vecini_in_q1:
            bge    $t5, $s1, vecini_adaugati1  

            lw     $s4, roles($t5)
            beq    $s4, $s6, vecin_verificat1

            mul    $t7, $t2, $s0              # $t7 = adresa liniei nodului curent
            add    $t7, $t7, $t5              # $t7 = matrice[nodCurent][coloana]
            lw     $t9, matrice($t7)
            
            beq    $t9, $t3, verificare_vecin1
            
            vecin_verificat1:
            addi   $t5, $t5, 4

            j adugare_vecini_in_q1

      vecini_adaugati1:
           
      j adaugare_nod_curent1

verificare_vecin1:
     lw   $s3, visited($t5)
     bne  $s3, $t3, verificare_vizitat1
     j vecin_verificat1

verificare_vizitat1:
     srl  $t5, $t5, 2
     sw   $t5, queue($t0)
     sll  $t5, $t5, 2
     addi $t0, $t0, 4
     sw   $t3, visited($t5)

     j vecin_verificat1

verificare_host_input:
    sll  $s5, $s5, 2
    lw   $t1, visited($s5)
  
    bne  $t1, $zero, destinatieGasita   #verific daca exista cel putin o legatura intre s4 si s5 

    beq  $t1, $zero, decriptare

decriptare:

   addi  $t0, $zero, 0           #index pe sirul de caractere "mesaj"
   
   lw    $s1, literaj                  #litera 'j' (j - 10 = z)
   lw    $s2, literaa
   lw    $t3, zece
   lw    $t4, literaz 
   lb    $s3, newLine
   decript_litera_cu_litera:	
       lb   $t1, mesaj($t0)
       beq  $t1, $zero, mesajDecriptat   # daca gasesc '\0' ma opresc

       ble  $t1, $s1, iesit_din_alfabet
       bgt  $t1, $s1, in_alfabet
      
       iesit_din_alfabet:
           sub     $t2, $t1, $s2
           addi    $t2, $t2, 1             #adaug 1 pt ca o sa scad din z, nu din a
           sub     $t5, $t3, $t2
           sub     $t6, $t4, $t5           #codul ascii al literei decriptate 
           sb      $t6, mesaj($t0)
           j urmatoarea_litera

       in_alfabet:
           sub     $t5, $t1, $t3
           sb      $t5, mesaj($t0)
           
           j urmatoarea_litera

         urmatoarea_litera:
         addi $t0, $t0, 1
       j decript_litera_cu_litera

destinatieGasita:
li $v0, 4
la $a0, mesaj
syscall
li $v0, 10
syscall

mesajDecriptat:
  
addi $t0, $zero, 0
printLoop:
lb   $t1, mesaj($t0)
beq  $t1, $s3, all_done

li   $v0, 11
move $a0, $t1
syscall

addi $t0, $t0, 1
j printLoop

all_done:
li $v0, 10
syscall
