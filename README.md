# Image-proccessing---Verilog

Pentru implementarea problemei am folosit un automat finit: 
• in primul bloc always actualizam starile, randurile si coloanele 
• in al doilea bloc, implementarea propriu zisa: 
I. prima etapa: partea de mirror 
  am utilizat 5 stari: 
   1. INCEPUT in care se executa urmatoarele: 
    -initializare cu zero   
   2. MIRROR: -se parcurge matricea pe coloane si doar jumatate din aceasta 
(jumatate din randuri) 
     -se initializeaza citirea  
    -se trece in urmatoarea stare 
 
    -se trece randul de la zero 
    -se trece pe urmatoarea coloana 
    -se reintoarce la inceputul starii 
       
    -se verifica finalizarea matricii de parcurs 
    -se finalizeaza procesul de MIRROR si se trece la urmatorul 
   3. SALVEZ_PIXEL: 
      -se salveaza intr-o variabila auxiliara pixelul de pe randul si coloana curenta 
      -se initializeaza trecerea in simetricul matricei (rand final - rand actual) 
      -urmatoarea stare 
   4. INTERSCHIMB_SI_SALVEZ: 
    -pe pozitia noua se scrie pixelul salvat anterior 
    -se salveaza pixelul de pe pozitia aceasta 
    -ne reintoarcea la randul initial 
    -deschid scrierea 
    -trec in urmatoarea stare 
    5. SALVEZ: 
    -salvez pixelul salvat la starea anterioara 
    -ma reintorc in starea MIRROR 
    -ma deplasez pe urmatorul rand 
 II. a doua etapa: partea de gray scale 
  am utilizat 4 stari: 
   1. START:  
    -revin la inceputul matricei 
    -initializez citirea 
   2. GRAYSCALE: 
    -de data aceasta parcurg toata matricea 
    -celelalte elemente sunt la fel ca la MIRROR 
   3. SALVEZ_PIXEL_CULORI: 
         -salvez primii 8 biti (23:16) din pixel in r, acesta reprezentant nuanta rosu 
         -urmatorii 8 (15:8) in g, 
        -ultimii 8 (7:0) in b 
        -verific care dintre r, g si b au cea mai mica valoarea si o salvez in min 
        -la fel fac si pentru max, doar ca in acest caz caut cea mai mare valoare 
        -fac media aritmetica dintre min si max 
        -merg in urmatoarea stare 
   4. SALVEZ_IN_G: 
    -actualizez noile valori ale culorilor 
    -le scriu in out_pix 
    -deschid scrierea 
    -trec la urmatorul rand 
    -ma intorc in starea GRAYSCALE pentru a finaliza matricea 
