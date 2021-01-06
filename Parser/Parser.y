%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
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

%type <i> skup_izraza 
%type <i> skup_rel_izraza 
%type <i> izraz 
%type <i> broj 
%type <i> parametar
%type <i> format_parametra

%type <i> poziv_funkcije
%type <i> poziv_funkcije_void
%type <i> argument
%type <i> format_agrumenata

%%

program
  : lista_funkcija 
    {
      if(lookup_symbol("Main", FUN) == NO_INDEX)
        err("Nedefinisana funkcija 'Main'");
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
  : ZAGO lista_promenjivih lista_operacija ZAGZ
  ;

lista_promenjivih
  :
  | lista_promenjivih promenjiva
  ;

promenjiva
  : TIP { tip_pomocna = $1; } format SEPARATOR_TACKA_ZAREZ
  ;

format
  : ID 
  {
  	if(tip_pomocna == VOID)
  		err("Promenjiva ne sme biti tipa VOID - [%s]", $1);
  	else
  	{
    	if(lookup_symbol($1, VAR|PAR) == NO_INDEX)
        	insert_symbol($1, VAR, tip_pomocna, ++var_brojac, NO_ATR, NO_ATR, NO_ATR);
      	else
        	err("Promenjiva sa datim imenom vec postoji - [%s]", $1);
	  }
  }
  | ID DOP broj
  {
    if(tip_pomocna == VOID)
      err("Promenjiva ne sme biti tipa VOID - [%s]", $1);

    else
      {
        if(lookup_symbol($1, VAR|PAR) == NO_INDEX)
           insert_symbol($1, VAR, tip_pomocna, ++var_brojac, NO_ATR, NO_ATR, NO_ATR);
        else
          err("Promenjiva sa datim imenom vec postoji - [%s]", $1);
      }

    if(get_type($3) != tip_pomocna)
      err("Nekompatibilne vrednosti, nemoguca dodela promenjivoj - [%s]", $1);

    set_atr2(lookup_symbol($1, VAR|PAR), 1); //ID koji ime neku vrednost dobija 1
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
  }
  | format SEPARATOR_ZAREZ ID DOP broj
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

    if(get_type($5) != tip_pomocna)
      err("Nekompatibilne vrednosti, nemoguca dodela promenjivoj - [%s]", $3);

    set_atr2(lookup_symbol($3, VAR|PAR), 1); //ID koji ime neku vrednost dobija 1
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
  : ID
      {
      	if(lookup_symbol($1, FUN) != NO_INDEX)
      		err("Nemoguca inkrementacija same funkcije - [%s]", $1);
      	else
      	{
      		int id_index = lookup_symbol($1, VAR|PAR);
        	if(id_index == NO_INDEX)
       	  	  err("Nepostojeci ID - [%s], nemoguca inkrementacija", $1);
        } 
      }
    INCR SEPARATOR_TACKA_ZAREZ
  ;

dekrementacija
  : ID
      {
      	if(lookup_symbol($1, FUN) != NO_INDEX)
      		err("Nemoguca dekrementacija same funkcije - [%s]", $1);
        else
      	{
        	int id_index = lookup_symbol($1, VAR|PAR);
        	if(id_index == NO_INDEX)
          	  err("Nepostojeci ID - [%s], nemoguca dekrementacija", $1);
  		  }
      } 
    DECR SEPARATOR_TACKA_ZAREZ
  ;

//INDIVIDUALNI ZADATAK 2

do_while_operacija
  : DO LOOP operacija END WHILE ZAGO skup_rel_izraza ZAGZ SEPARATOR_TACKA_ZAREZ
  ;

//INDIVIDUALNI ZADATAK 2

//INDIVIDUALNI ZADATAK 3

  check_operacija
  : CHECK ZAGO ID 
  { 
    check_tip = get_type(lookup_symbol($3, VAR|PAR));

    int pomocna_ID_index = lookup_symbol($3, VAR|PAR);

    if(pomocna_ID_index == NO_INDEX)
      err("Ne postoji ID za koji moze da se izvrsi check operacija - %s", $3);
  } 
  ZAGZ IF_ZAGO check_operacija_case check_operacija_default IF_ZAGZ
  {
    for(int i = fun_indeks_pomocna+1; i <= get_last_element(); i++)
      if(get_kind(i) == LIT)
        if(get_atr1(i) == 1)
          set_atr1(i, 0);
  }
  ;

  check_operacija_case
  : CASE broj SEPARATOR_DVE_TACKE operacija check_operacija_break 
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
  }
  | check_operacija_case CASE broj SEPARATOR_DVE_TACKE operacija check_operacija_break 
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
  }
  ;

  check_operacija_break
  :
  | BREAK SEPARATOR_TACKA_ZAREZ 
  ;

  check_operacija_default
  :
  | DEFAULT SEPARATOR_DVE_TACKE operacija
  ;

//INDIVIDUALNI ZADATAK 3

dodela
  : ID DOP skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      int id_index = lookup_symbol($1, VAR|PAR);
      if(id_index == NO_INDEX)
        err("Nepostojeci ID, nemoguca dodela - [%s]", $1);
      else if(get_type(id_index) != get_type($3))
        err("Razliciti tipovi, nemoguca dodela");

      set_atr2(lookup_symbol($1, VAR|PAR), 1); //ID koji ime neku vrednost dobija 1

    }
  ;

if_operacija
  : if_deo %prec ONLY_IF
  | if_deo ELSE operacija
  ;

if_deo
  : IF ZAGO skup_rel_izraza ZAGZ operacija
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
    }
  ;

skup_rel_izraza
  : skup_izraza ROP skup_izraza
    {
      if(get_type($1) != get_type($3))
        err("Razliciti tipovi, nemoguca operacija");
    }
  ;

skup_izraza
  : izraz
  | skup_izraza AOP izraz
    {
      if(get_type($1) != get_type($3))
        err("Razliciti tipovi, nemoguca dodela");
    }
  ;

izraz
  : broj
  | ID
    {
      $$ = lookup_symbol($1, VAR|PAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
    }
  | ID INCR
    {
      $$ = lookup_symbol($1, VAR|PAR);
      if($$ == NO_INDEX)
      	err("ID ne postoji, nemoguca inkrementacija - [%s]", $1);
    }
  | ID DECR
    {
      $$ = lookup_symbol($1, VAR|PAR);
      if($$ == NO_INDEX)
        err("ID ne postoji, nemoguca dekrementacija - [%s]", $1);
    }
  | poziv_funkcije
  | ZAGO skup_izraza ZAGZ
    {
      $$ = $2;
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
      set_type(FUN_REG, get_type(fun_poziv_pomocna));
      brojac_argumenata = 0; //na kraju poziva funkcije resetujemo
      $$ = FUN_REG;
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
      {
        /*PROVERA BROJA ARGUMENATA
        printf("Broj argumenata -> %d\n", brojac_argumenata);
        printf("Ocekivano argumenata -> %d\n", get_atr1(fun_poziv_pomocna) + get_atr3(fun_poziv_pomocna));
        printf("ATR1 -> %d\n", get_atr1(fun_poziv_pomocna));
        printf("ATR3 -> %d\n", get_atr3(fun_poziv_pomocna));*/
  			err("Pogresan broj argumenata za pozvanu funkciju - [%s]", get_name(fun_poziv_pomocna));
      }
  		set_type(FUN_REG, get_type(fun_poziv_pomocna));
      brojac_argumenata = 0; //na kraju poziva funkcije resetujemo
  		$$ = FUN_REG;
  	}
  ;

argument
	: { $$ = 0; }
	| format_agrumenata
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
    brojac_argumenata++; //povecavamo broj argumenata
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
    brojac_argumenata++; //povecavamo broj argumenata
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

void proveraArgumenata()
{
  printf("ID_FUNKCIJE | ARGUMENTI_FUNKCIJE\n");
  printf("--------------------------------\n");
  for(int i = 0; i < get_last_element(); i++)
  {
    if(nizParametara[i].id!=0)
      printf("     %d             ", nizParametara[i].id);
    for(int j = 0; j < get_last_element(); j++)
      if(nizParametara[i].tipovi[j]!=0)
        printf("%d ", nizParametara[i].tipovi[j]);
    printf("\n\n");
  }
}

int main() 
{ 
  int synerr;

  init_symtab();

  synerr = yyparse();

  //print_symtab(); -> provera tabele posle parsiranja

  //proveraArgumenata();

  clear_symtab();

  if(broj_gresaka)
    printf("\n Broj GRESAKA: [%d] \n", broj_gresaka);

  if(broj_upozorenja)
    printf("\n Broj UPOZORENJA: [%d] \n", broj_upozorenja);

  if(synerr)
    return -1;
  else
    return broj_gresaka;

  yyparse(); 
}