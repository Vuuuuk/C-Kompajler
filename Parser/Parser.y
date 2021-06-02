%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"

  #include <string.h> //CASE SENSITIVE Main/main

  //maksimalno 64 parametara i 64 funkcije
  #define MAX 64 


  int yylex(void);
  int yyparse(void);
  int yyerror(char *s);
  void warning(char *s);

  //pomocna struktura za argumente funckije
  struct parametriFunkcije
  {
    unsigned id; //id funkcije
    unsigned tipovi[MAX]; //niz tipova argumenata
  };

  struct parametriFunkcije nizParametara[MAX]; //niz struktura
  int br = 0; //index za niz ID-ova funkcije
  int paramsBr = 0; //brojac parametara

  int brojac_argumenata = 0; //pomocna, broj arguemanta
  int pomocna_tip_argumenata = 0; //pomocna za tip argumenata

  extern int yylineno;

  char char_buffer[CHAR_BUFFER_LENGTH];
  int broj_gresaka = 0;
  int broj_upozorenja = 0;
  int var_brojac = 0;
  int fun_indeks_pomocna = -1;
  int fun_poziv_pomocna = -1;

  //pomocna za cuvanje tipa, iz pojma promenjiva;
  int tip_pomocna = 0; 

  //pomocna za return
  bool return_pomocna = 0;

  //pomocna za broj parametara_INT/UINT
  int broj_parametara_int = 0;
  int broj_parametara_uint = 0;

  //pomocna za redni_broj nekog parametra
  int redni_broj_parametara = 0;

  //pomocna za individualni zadatak 3
  int check_tip = 0;

  //pomocne za PUSH argumenata u obrnutom/pravom redosledu
  int niz_argumenata[MAX]; //niz za cuvanje index-a argumenata
  void PushArgumenata(); //funkcija za PUSH argumenata u obrnutom/pravom redosledu

  //GENERISANJE KODA
  int out_lin = 0; 
  int lab_num = -1; //brojac za generisanje labela, kako ne bi imali dve iste
  FILE *output; //fajl za upisivanje generisanog asm koda

  int niz_inkrementacija[MAX]; //niz za smestanje param za inkrementaciju
  int brojac_inkrementacija; //brojac param za inkrementaciju

  //INDIVIDUALNI ZADATAK 1 - prosirenje .ceo a, b, c = 1 (a,b,c dobijaju 1)
  int individualni_zadatak1_id_pomocna = 0;
  int niz_pormenjivih_sa_dodelom[MAX];
  int brojac_niza_promenjivih_sa_dodelom = 0;

  //INDIVIDUALNI ZADATAK 2 - generisanje
  int max_do = -1;
  int brojac_duova = 0;

  //INDIVIDUALNI ZADATAK 3 - generisanje
  int check_id_pomocna = 0;
  int case_brojac = -1;
  int case_kraj_brojac = -1;

  //funkcija za izvrsavanje inkrementacije na kraju
  void proveri_inkrement();

%}

%union { int i; char *s; }

%token _FUN
%token F_ZAGO
%token F_ZAGZ

%token ZAGO
%token ZAGZ

%token SEPARATOR_ZAREZ
%token SEPARATOR_TACKA_ZAREZ

%token <i> TIP

%token <s> _BOOL
%token <s> _INT
%token <s> _U_INT
%token <s> _FLOAT

%token <s> ID

%token <i> ROP
%token <i> AOP
%token <i> DOP

%token INCR
%token DECR

//"lazni" token, bitno zbog prioriteta, viseci ELSE problem
%nonassoc ONLY_IF 
%token IF
%nonassoc ELSE 
%token IF_ZAGO
%token IF_ZAGZ

%token IZLZ

//INDIVIDUALNI ZADATAK 2
%token DO
%token LOOP
%token END
%token WHILE

//INDIVIDUALNI ZADATAK 3
%token CHECK
%token CASE
%token SEPARATOR_DVE_TACKE
%token BREAK
%token DEFAULT

//ZAJEDNICKI ZADATAK 13
%token COND_IF

%type <i> skup_izraza 
%type <i> skup_rel_izraza 
%type <i> izraz 
%type <i> broj 
%type <i> parametar
%type <i> format_parametra

%type <i> if_deo

%type <i> poziv_funkcije
%type <i> poziv_funkcije_void
%type <i> argument
%type <i> format_agrumenata


%type <i> uslovni_izraz
%type <i> uslovni_parametar

%%

program
  : global_lista lista_funkcija 
    {
      if(lookup_symbol("Main", FUN) == NO_INDEX)
        err("Nedefinisana funkcija 'Main'");
    }
  ; 

global_lista
  :
  | global_lista global_promenjiva
  ;

global_promenjiva
  : TIP ID SEPARATOR_TACKA_ZAREZ
  {
    int glob_pomocna = lookup_symbol($2, GVAR);
    if (glob_pomocna != NO_INDEX) 
        err("Redefinicija promenljive: '%s'", $2);
    else 
    {
      insert_symbol($2, GVAR, $1, NO_ATR, NO_ATR, NO_ATR, NO_ATR);
      code("\n%s:\n\t\tWORD\t1", $2);
    }
  }
  ;

lista_funkcija
  : funkcija
  | lista_funkcija funkcija
  ;

funkcija
  : _FUN TIP ID 
    {
      fun_indeks_pomocna = lookup_symbol($3, FUN);
      if(fun_indeks_pomocna == NO_INDEX)
      {
        fun_indeks_pomocna = insert_symbol($3, FUN, $2, NO_ATR, NO_ATR, NO_ATR, NO_ATR);
        nizParametara[br].id = fun_indeks_pomocna; //u niz upisujemo id funkcije
      }
      else
        err("Funkcija sa datim imenom vec postoji - [%s] ", $3);
        //Iz nekog razloga Main mora da bude malim da bi HIPSIM radio
        //Moja leksika je drugacija i ID pocinje velikim slovom
        //Ne mogu da izmenim to pravilo i nisam uspeo da pronadjem u cemu je greska
        //Morao sam ovako
        if(strcmp(get_name(fun_indeks_pomocna), "Main") == 0)
        {
          code("\nmain:");
          code("\n\t\tPUSH\t%%14");
          code("\n\t\tMOV \t%%15,%%14");
        }
        else
        {
          code("\n%s:", $3);
          code("\n\t\tPUSH\t%%14");
          code("\n\t\tMOV \t%%15,%%14");
        }
    }
    F_ZAGO parametar F_ZAGZ telo
    {
      for(int i = fun_indeks_pomocna+1; i <= get_last_element(); i++)
        if(get_kind(i) == VAR && get_atr2(i) == 0)
          err("Promenjiva je kreirana ali nema dodeljenu vrednost - %s", get_name(i));

      if(return_pomocna == 0 && $2 != VOID)
        warn("Funkcija mora da vrati neku vrednost - [%s]", $3);

      clear_symbols(fun_indeks_pomocna + 1);
      br++; //povecamo brojac za pristupanje nizu funkcija
      paramsBr = 0; 
      var_brojac = 0;
      return_pomocna = 0;
      redni_broj_parametara = 0;
      broj_parametara_int = 0;
      broj_parametara_uint = 0;

      if(strcmp(get_name(fun_indeks_pomocna), "Main") == 0)
      {
        code("\n@main_exit:");
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
      else
      {
        code("\n@%s_exit:", $3);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
    }
  ;

parametar
  :
    {
      set_atr1(fun_indeks_pomocna, 0);
      set_atr3(fun_indeks_pomocna, 0);
    }
  | format_parametra
  ;

format_parametra
  : TIP ID
    {
      if($1 == VOID)
        err("Parametar ne sme biti tipa VOID - [%s]", $2);
      if(lookup_symbol($2, PAR) == NO_INDEX)
      {
        if($1 == INT)
        {
         nizParametara[br].tipovi[paramsBr] = $1; //upisujemo tip argumenta u odgovarajucu funkciju
         insert_symbol($2, PAR, $1, ++redni_broj_parametara, NO_ATR, NO_ATR, NO_ATR);
         set_atr1(fun_indeks_pomocna, ++broj_parametara_int);
         set_atr2(fun_indeks_pomocna, $1);
        }
        else if($1 == UINT)
        {
         nizParametara[br].tipovi[paramsBr] = $1;
         insert_symbol($2, PAR, $1, ++redni_broj_parametara, NO_ATR, NO_ATR, NO_ATR);
         set_atr3(fun_indeks_pomocna, ++broj_parametara_uint);
         set_atr4(fun_indeks_pomocna, $1);
        }
        paramsBr++; //povecavanje brojaca, prebacivanje na sledeci index
      }
      else
        err("Parametar vec postoji u funkciji - [%s]", $2);
    }
  | format_parametra SEPARATOR_ZAREZ TIP ID
    {
        if($3 == VOID)
        err("Parametar ne sme biti tipa VOID - [%s]", $4);
        if(lookup_symbol($4, PAR) == NO_INDEX)
          {
            if($3 == INT)
            {
              nizParametara[br].tipovi[paramsBr] = $3;
              insert_symbol($4, PAR, $3, ++redni_broj_parametara, NO_ATR, NO_ATR, NO_ATR);
              set_atr1(fun_indeks_pomocna, ++broj_parametara_int);
              set_atr2(fun_indeks_pomocna, $3);
            }
            else if($3 == UINT)
            {
              nizParametara[br].tipovi[paramsBr] = $3;
              insert_symbol($4, PAR, $3, ++redni_broj_parametara, NO_ATR, NO_ATR, NO_ATR);
              set_atr3(fun_indeks_pomocna, ++broj_parametara_uint);
              set_atr4(fun_indeks_pomocna, $3);
            }
            paramsBr++;
          }
        else
          err("Parametar vec postoji u funkciji - [%s]", $4);

        // print_symtab(); -> provera indeksa parametara funkcije
    }
  ;

telo
  : ZAGO lista_promenjivih 
  {
    if(var_brojac)
      code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_brojac);
    if(strcmp(get_name(fun_indeks_pomocna), "Main") == 0)
      code("\n@main_body:");
    else
      code("\n@%s_body:", get_name(fun_indeks_pomocna));
  }
  lista_operacija ZAGZ
  ;

lista_promenjivih
  :
  | lista_promenjivih promenjiva 
  ;

promenjiva
  : TIP { tip_pomocna = $1; } format format_dodela SEPARATOR_TACKA_ZAREZ 
  ;

format
  : ID 
  {
  	if(tip_pomocna == VOID)
  		err("Promenjiva ne sme biti tipa VOID - [%s]", $1);
  	else
  	{
    	if(lookup_symbol($1, VAR|PAR) == NO_INDEX) //Mislio sam da ovde treba da pretrazujem i 
        //GVAR medjutim receno je u zadataku da mogu lokalne i globalne da imaju isto ime
        insert_symbol($1, VAR, tip_pomocna, ++var_brojac, NO_ATR, NO_ATR, NO_ATR);
      	else
        	err("Promenjiva sa datim imenom vec postoji - [%s]", $1);
	  }
    individualni_zadatak1_id_pomocna = lookup_symbol($1, VAR|PAR);
    niz_pormenjivih_sa_dodelom[brojac_niza_promenjivih_sa_dodelom] = individualni_zadatak1_id_pomocna;
    brojac_niza_promenjivih_sa_dodelom++;
  }
  | format SEPARATOR_ZAREZ ID
  {
  	if(tip_pomocna == VOID)
  		err("Promenjiva ne sme biti tipa VOID - [%s]", $3);
  	else
  	{
  		if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
    		insert_symbol($3, VAR, tip_pomocna, ++var_brojac, NO_ATR, NO_ATR, NO_ATR);
    	else
    		err("Promenjiva sa datim imenom vec postoji - [%s]", $3);
	  }
    individualni_zadatak1_id_pomocna = lookup_symbol($3, VAR|PAR);
    niz_pormenjivih_sa_dodelom[brojac_niza_promenjivih_sa_dodelom] = individualni_zadatak1_id_pomocna;
    brojac_niza_promenjivih_sa_dodelom++;
  }
  ;

format_dodela
  :
  | DOP broj
  {
    if(tip_pomocna != get_type($2))
      err("Razliciti tipovi, nemoguca dodela!");
    for(int i = 0; i < brojac_niza_promenjivih_sa_dodelom; i++)
    {
      set_atr2(niz_pormenjivih_sa_dodelom[i], 1); //ID koji ime neku vrednost dobija 1
      gen_mov($2, niz_pormenjivih_sa_dodelom[i]);
    }
    brojac_niza_promenjivih_sa_dodelom = 0;
  }
  ;

lista_operacija
  :
  | lista_operacija operacija
  ;

operacija
  : inkrementacija
  | dekrementacija
  | do_while_operacija        // drugi individualni zadatak
  | check_operacija           // treci individualni zadatak
  | poziv_funkcije_void       // omogucen samostalan poziv funkcije tipa VOID
  | dodela
  | if_operacija
  | grupa_operacija
  | izlaz
  ;

inkrementacija
  : ID INCR SEPARATOR_TACKA_ZAREZ
    {
      if(lookup_symbol($1, FUN) != NO_INDEX)
        err("Nemoguca inkrementacija same funkcije - [%s]", $1);
      else
      {
        int id_index = lookup_symbol($1, VAR|PAR|GVAR);
        if(id_index == NO_INDEX)
            err("Nepostojeci ID - [%s], nemoguca inkrementacija", $1);
        if(get_type(id_index) == INT)
          code("\n\t\tADDS\t");
        else
          code("\n\t\tADDU\t");
        gen_sym_name(id_index);
        code(", $1, ");
        gen_sym_name(id_index);
        brojac_inkrementacija = 0;
      } 
    }
  ;

dekrementacija //nije odradjeno generisanje koda, dodatni deo
  : ID
      {
      	if(lookup_symbol($1, FUN) != NO_INDEX)
      		err("Nemoguca dekrementacija same funkcije - [%s]", $1);
        else
      	{
        	int id_index = lookup_symbol($1, VAR|PAR|GVAR);
        	if(id_index == NO_INDEX)
          	  err("Nepostojeci ID - [%s], nemoguca dekrementacija", $1);
  		  }
      } 
    DECR SEPARATOR_TACKA_ZAREZ
  ;

//INDIVIDUALNI ZADATAK 2

do_while_operacija
  : DO LOOP 
  {
    ++lab_num;
    ++brojac_duova;
    if(lab_num > max_do)
      max_do = lab_num;
    code("\n@while_TRUE%d:", lab_num);
  }
  operacija END WHILE
  {
    code("\n@while_PROVERA%d:", lab_num);
  }
  ZAGO skup_rel_izraza ZAGZ SEPARATOR_TACKA_ZAREZ
  {
    code("\n\t\t%s\t@while_TRUE%d", jumps[$9], lab_num);
    code("\n\t\t%s\t@while_FALSE%d", opp_jumps[$9], lab_num);

    code("\n@while_FALSE%d:", lab_num);
    code("\n@while_EXIT%d:", lab_num);
    if(--brojac_duova)
      --lab_num;
    else
      lab_num = max_do;
  }
  ;

//INDIVIDUALNI ZADATAK 2

//INDIVIDUALNI ZADATAK 3

  check_operacija
  : CHECK ZAGO ID 
  { 
    ++case_kraj_brojac;

    check_tip = get_type(lookup_symbol($3, VAR|PAR));

    int pomocna_ID_index = lookup_symbol($3, VAR|PAR);

    if(pomocna_ID_index == NO_INDEX)
      err("Ne postoji ID za koji moze da se izvrsi check operacija - %s", $3);

    check_id_pomocna = pomocna_ID_index;
  } 
  ZAGZ IF_ZAGO check_operacija_case check_operacija_default IF_ZAGZ
  {
    for(int i = fun_indeks_pomocna+1; i <= get_last_element(); i++)
      if(get_kind(i) == LIT)
        if(get_atr1(i) == 1)
          set_atr1(i, 0);
    code("\n@check_EXIT%d:", case_kraj_brojac);
  }
  ;

  check_operacija_case
  : CASE broj 
  { 
    if(get_type($2) != check_tip)
      err("Tip check operacije se ne podudara sa tipom ID-a za koji vrsimo proveru [CASE] - %s", get_name($2));
    else
    {
      //Provera da li je bio iskoriscen
      if(get_atr1($2) == NO_ATR)
        set_atr1($2,1);
      else
        err("Case %s vec definisan", get_name($2));
    }
    gen_cmp(check_id_pomocna, $2);
    code("\n\t\t%s\t@check_CASE%d",opp_jumps[4],++lab_num);
  }
  SEPARATOR_DVE_TACKE operacija check_operacija_break
  {
    code("\n@check_CASE%d:",lab_num);
  }
  | check_operacija_case CASE broj 
  {
    if(get_type($3) != check_tip)
      err("Tip check operacije se ne podudara sa tipom ID-a za koji vrsimo proveru [CASE] - %s", get_name($3));
    else
    {
      //Provera da li je bio iskoriscen
      if(get_atr1($3) == NO_ATR)
        set_atr1($3,1);
      else
        err("Case %s vec definisan", get_name($3));
    }
    gen_cmp(check_id_pomocna,$3);
    code("\n\t\t%s\t@check_CASE%d",opp_jumps[4],++lab_num);
  }
  SEPARATOR_DVE_TACKE operacija check_operacija_break
  {
    code("\n@check_CASE%d:",lab_num);
  }
  ;

  check_operacija_break
  :
  | BREAK SEPARATOR_TACKA_ZAREZ 
  {
    code("\n\t\tJMP\t\t@check_EXIT%d", case_kraj_brojac);
  }
  ;

  check_operacija_default
  :
  | DEFAULT SEPARATOR_DVE_TACKE operacija
  ;

//INDIVIDUALNI ZADATAK 3

dodela
  : ID DOP skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      int id_index = lookup_symbol($1, VAR|PAR|GVAR);
      if(id_index == NO_INDEX)
        err("Nepostojeci ID, nemoguca dodela - [%s]", $1);
      else if(get_type(id_index) != get_type($3))
        err("Razliciti tipovi, nemoguca dodela");

      set_atr2(lookup_symbol($1, VAR|PAR|GVAR), 1); //ID koji ime neku vrednost dobija 1

      proveri_inkrement();

      gen_mov($3, id_index);

    }
  ;

if_operacija
  : if_deo %prec ONLY_IF
    { code("\n@exit%d:", $1); }
  | if_deo ELSE operacija
    { code("\n@exit%d:", $1); }
  ;

if_deo
  : IF ZAGO 
  {
    $<i>$ = ++lab_num;
    code("\n@if%d:", lab_num);
  }
  skup_rel_izraza 
  {
    code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3); 
    code("\n@true%d:", $<i>3);
  }
  ZAGZ operacija
  {
    code("\n\t\tJMP \t@exit%d", $<i>3);
    code("\n@false%d:", $<i>3);
    $$ = $<i>3;
  }
  ;

//ZAJEDNICKI ZADATAK 13
uslovni_izraz
  : ZAGO skup_rel_izraza 
  {
    code("\n\t\t%s\t@uslovFALSE%d", opp_jumps[$2], ++lab_num);  
  }
  ZAGZ COND_IF uslovni_parametar SEPARATOR_DVE_TACKE uslovni_parametar
  {
    if(get_type($6) != get_type($8))
      err("Razliciti tipovi uslovnih parametara - [%s] i [%s]", get_name($6), get_name($8));
    else
    {
      int reg = take_reg(); //zauzimanje jednog registra
      code("\n@uslovTRUE%d:", lab_num);
      gen_mov($6, reg);
      code("\n\t\tJMP\t\t@uslov_EXIT%d", lab_num);
      code("\n@uslovFALSE%d:", lab_num);
      gen_mov($8, reg);
      code("\n@uslov_EXIT%d:", lab_num);
      $$ = reg;
    }
  }
  ;

uslovni_parametar
  : ID
  {
    int pomocna_index = lookup_symbol($1, VAR|PAR|GVAR);
      if(pomocna_index == NO_INDEX)
        err("Promenjiva nije deklarisana, uslovni parametar - [%s]", $1);
    $$ = pomocna_index;
  }
  | broj
  ;

grupa_operacija
  : ZAGO lista_operacija ZAGZ
  ;

izlaz
  : IZLZ SEPARATOR_TACKA_ZAREZ
  	{
      return_pomocna = 1;
      if(get_type(fun_indeks_pomocna) == INT || get_type(fun_indeks_pomocna) == UINT)
      	warn("Funkcija treba da vratu neku vrednost, odgovarajuceg tipa - [%s]", get_name(fun_indeks_pomocna));
  	}
  | IZLZ {return_pomocna = 1;} skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      if(get_type(fun_indeks_pomocna) == VOID)
      	err("Funkcija je tipa void, ne sme da ima RETURN - [%s]", get_name(fun_indeks_pomocna));
      else
      {
      	if(get_type(fun_indeks_pomocna) != get_type($3))
        	err("Razliciti tipovi, IZLAZ nije moguc");
	    }
      gen_mov($3, FUN_REG);
      if(strcmp(get_name(fun_indeks_pomocna), "Main") == 0)
        code("\n\t\tJMP \t@main_exit");
      else
        code("\n\t\tJMP \t@%s_exit", get_name(fun_indeks_pomocna));
    }
  ;

skup_rel_izraza
  : skup_izraza ROP skup_izraza
    {
      if(get_type($1) != get_type($3))
        err("Razliciti tipovi, nemoguca operacija");
      $$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);
      gen_cmp($1, $3);
    }
  ;

skup_izraza
  : izraz 
  | skup_izraza AOP izraz
    {
      if(get_type($1) != get_type($3))
        err("Razliciti tipovi, nemoguca dodela");
      int t1 = get_type($1);    
      code("\n\t\t%s\t", ar_instructions[$2 + ((t1 - 1) * AROP_NUMBER)]);
      gen_sym_name($1);
      code(",");
      gen_sym_name($3);
      code(",");
      free_if_reg($3);
      free_if_reg($1);
      $$ = take_reg();
      gen_sym_name($$);
      set_type($$, t1);
    }
  ;

izraz
  : broj
  | ID
    {
      $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
    }
  | ID INCR
    {
      $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
      	err("ID ne postoji, nemoguca inkrementacija - [%s]", $1);
      niz_inkrementacija[brojac_inkrementacija] = lookup_symbol($1, VAR|PAR|GVAR);
      brojac_inkrementacija++;
    }
  | ID DECR
    {
      $$ = lookup_symbol($1, VAR|PAR|GVAR);
      if($$ == NO_INDEX)
        err("ID ne postoji, nemoguca dekrementacija - [%s]", $1);
    }
  | poziv_funkcije
    {
      $$ = take_reg();
      gen_mov(FUN_REG, $$);
    }
  | ZAGO skup_izraza ZAGZ
    {
      $$ = $2;
    }
  | uslovni_izraz
    {
      $$ = $1;
    }
  ;

poziv_funkcije_void
  : ID
    {
      fun_poziv_pomocna = lookup_symbol($1, FUN);
      if(fun_poziv_pomocna == NO_INDEX)
        err("Funkcija koju ste pokusali da pozovete ne postoji - [%s]", $1);

      if(get_type(fun_poziv_pomocna) != VOID)
        err("Nemoguc samostalan poziv za funkciju koja nije tipa VOID - [%s]", $1);
    }
  ZAGO argument ZAGZ SEPARATOR_TACKA_ZAREZ
    {
      if((get_atr1(fun_poziv_pomocna) + get_atr3(fun_poziv_pomocna)) != $4)
        err("Pogresan broj argumenata za pozvanu funkciju - [%s]", get_name(fun_poziv_pomocna));
        if(strcmp(get_name(fun_poziv_pomocna), "Main") == 0)
        code("\n\t\t\tCALL\tmain");
        else
        code("\n\t\t\tCALL\t%s", get_name(fun_poziv_pomocna));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15",$4 * 4);
        set_type(FUN_REG, get_type(fun_poziv_pomocna));
        $$ = FUN_REG;
        brojac_argumenata = 0; //na kraju poziva funkcije resetujemo
    }
  ;

poziv_funkcije
  : ID
  	{
  		fun_poziv_pomocna = lookup_symbol($1, FUN);
  		if(fun_poziv_pomocna == NO_INDEX)
  			err("Funkcija koju ste pokusali da pozovete ne postoji - [%s]", $1);
  	}
  ZAGO argument ZAGZ
  	{
  		if((get_atr1(fun_poziv_pomocna) + get_atr3(fun_poziv_pomocna)) != $4)
  			err("Pogresan broj argumenata za pozvanu funkciju - [%s]", get_name(fun_poziv_pomocna));

      /*PROVERA BROJA ARGUMENATA
        printf("Broj argumenata -> %d\n", brojac_argumenata);
        printf("Ocekivano argumenata -> %d\n", get_atr1(fun_poziv_pomocna) + get_atr3(fun_poziv_pomocna));
        printf("ATR1 -> %d\n", get_atr1(fun_poziv_pomocna));
        printf("ATR3 -> %d\n", get_atr3(fun_poziv_pomocna));*/
        if(strcmp(get_name(fun_poziv_pomocna), "Main") == 0)
        code("\n\t\t\tCALL\tmain");
        else
        code("\n\t\t\tCALL\t%s", get_name(fun_poziv_pomocna));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15",$4 * 4);
        set_type(FUN_REG, get_type(fun_poziv_pomocna));
        $$ = FUN_REG;
        brojac_argumenata = 0; //na kraju poziva funkcije resetujemo
  	}
  ;

argument
	: { $$ = 0; }
  //pozivanje posle cuvanja svih argumenata
	| format_agrumenata { PushArgumenata(); }
	;

format_agrumenata
  : skup_izraza 
  { 
    pomocna_tip_argumenata = get_type($1); //pomocna za tip parametara
    for(int i = 0; i < get_last_element(); i++)
    {
      if(fun_poziv_pomocna == nizParametara[i].id)
      {
        if(nizParametara[i].tipovi[brojac_argumenata] != pomocna_tip_argumenata)
          err("Pogresan red argumenata u funkciji [%s]", get_name(fun_poziv_pomocna));
      }
    }
    niz_argumenata[brojac_argumenata] = $1; //upisujemo index argumenta u niz
    brojac_argumenata++; //povecavamo broj argumenata
    free_if_reg($1); 
    $$ = brojac_argumenata;
  }
  | format_agrumenata SEPARATOR_ZAREZ skup_izraza
  {
    pomocna_tip_argumenata = get_type($3); //pomocna za rip parametara
    for(int i = 0; i < get_last_element(); i++)
    {
      if(fun_poziv_pomocna == nizParametara[i].id)
      {
        if(nizParametara[i].tipovi[brojac_argumenata] != pomocna_tip_argumenata)
          err("Pogresan red argumenata u funkciji [%s]", get_name(fun_poziv_pomocna));
      }
    }
    niz_argumenata[brojac_argumenata] = $3;
    brojac_argumenata++; //povecavamo broj argumenata
    free_if_reg($3);
    $$ = brojac_argumenata;
  }
  ;

broj
  : _INT   { $$ = insert_literal($1, INT);   }
  | _U_INT { $$ = insert_literal($1, UINT);  }
  | _FLOAT { $$ = insert_literal($1, FLOAT); }
  | _BOOL  { $$ = insert_literal($1, BOOL);  }
  ;

%%

int yyerror(char *s) 
{ 
  fprintf(stderr, "\nSintaksna greska na liniji [%d] - %s\n", yylineno, s);
  broj_gresaka++;
  return 0; 
} 

void warning(char *s)
{
  fprintf(stderr, "\n[LINIJA -> %d]: UPOZORENJE - %s \n", yylineno, s);
  broj_upozorenja++;
}

void PushArgumenata()
{
  for(int i = brojac_argumenata; i >= 0; i--)
  {
    code("\n\t\t\tPUSH\t");
    gen_sym_name(niz_argumenata[i]);
  }
}

void proveri_inkrement()
{
  for(int i = 0; i < brojac_inkrementacija; i++)
  {
    if(get_type(niz_inkrementacija[i]) == INT)
      code("\n\t\tADDS\t");
    else
      code("\n\t\tADDU\t");
    gen_sym_name(niz_inkrementacija[i]);
    code(", $1, ");
    gen_sym_name(niz_inkrementacija[i]);
  }
  brojac_inkrementacija = 0;
}

int main() 
{ 
  int synerr;

  init_symtab();

  output = fopen("output.asm", "w+");

  synerr = yyparse();

  //print_symtab(); -> provera tabele posle parsiranja

  clear_symtab();

  fclose(output);

  if(broj_upozorenja)
    printf("\n Broj UPOZORENJA: [%d] \n", broj_upozorenja);

  if(broj_gresaka)
  {
    remove("output.asm");
    printf("\n Broj GRESAKA: [%d] \n", broj_gresaka);
  }

  if(synerr)
    return -1;
  else
    return broj_gresaka;
}