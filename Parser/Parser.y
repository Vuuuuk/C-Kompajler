%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"


  int yylex(void);
  int yyparse(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;

  char char_buffer[CHAR_BUFFER_LENGTH];
  int broj_gresaka = 0;
  int broj_upozorenja = 0;
  int var_brojac = 0;
  int fun_indeks_pomocna = -1;
  int fun_poziv_pomocna = -1;

  //pomocna za cuvanje tipa, iz pojma promenjiva;
  int tip_pomocna = 0; 
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

%type <i> skup_izraza 
%type <i> skup_rel_izraza 
%type <i> izraz 
%type <i> broj 
%type <i> parametar

%type <i> poziv_funkcije
%type <i> argument

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
        fun_indeks_pomocna = insert_symbol($3, FUN, $2, NO_ATR, NO_ATR);
      else
        err("Funkcija sa datim imenom vec postoji - [%s] ", $3);
    }
    F_ZAGO parametar F_ZAGZ telo
    {
      clear_symbols(fun_indeks_pomocna + 1);
      var_brojac = 0;
    }
  ;

parametar
  :
    {
      set_atr1(fun_indeks_pomocna, 0);
    }
  | TIP ID
    {
      if($1 == VOID)
      	err("Parametar ne sme biti tipa VOID - [%s]", $2);
      else
      {
      	insert_symbol($2, PAR, $1, 1, NO_ATR);
      	set_atr1(fun_indeks_pomocna, 1);
      	set_atr2(fun_indeks_pomocna, $1);
  	  }
    }
  ;

telo
  : ZAGO lista_promenjivih lista_operacija izlaz ZAGZ
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
        	insert_symbol($1, VAR, tip_pomocna, ++var_brojac, NO_ATR);
      	else
        	err("Promenjiva sa datim imenom vec postoji - [%s]", $1);
	}
  }
  | format SEPARATOR_ZAREZ ID
  {
  	if(tip_pomocna == VOID)
  		err("Promenjiva ne sme biti tipa VOID - [%s]", $3);
  	else
  	{
  		if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
    		insert_symbol($3, VAR, tip_pomocna, ++var_brojac, NO_ATR);
    	else
    		err("Promenjiva sa datim imenom vec postoji - [%s]", $3);
	}
  }
  ;

lista_operacija
  :
  | lista_operacija operacija
  ;

operacija
  : inkrementacija
  | dekrementacija
  | dodela
  | if_operacija
  | grupa_operacija
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
      	{
        	int id_index = lookup_symbol($1, VAR|PAR);
        	if(id_index == NO_INDEX)
          	  err("Nepostojeci ID - [%s], nemoguca dekrementacija", $1);
  		}
      } 
    DECR SEPARATOR_TACKA_ZAREZ
  ;

dodela
  : ID DOP skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      int id_index = lookup_symbol($1, VAR|PAR);
      if(id_index == NO_INDEX)
        err("Nepostojeci ID, nemoguca dodela - [%s]", $1);
      else
        if(get_type(id_index) != get_type($3))
          err("Razliciti tipovi, nemoguca dodela");
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
  : 
  	{
  		if(get_type(fun_indeks_pomocna) == INT || get_type(fun_indeks_pomocna) == UINT)
    		warn("Funkcija treba da vratu neku vrednost, odgovarajuceg tipa - [%s]", get_name(fun_indeks_pomocna));
  	}
  | IZLZ SEPARATOR_TACKA_ZAREZ
  	{
      	if(get_type(fun_indeks_pomocna) == INT || get_type(fun_indeks_pomocna) == UINT)
      		warn("Funkcija treba da vratu neku vrednost, odgovarajuceg tipa - [%s]", get_name(fun_indeks_pomocna));
  	}
  | IZLZ skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      if(get_type(fun_indeks_pomocna) == VOID)
      	err("Funkcija je tipa void, ne sme da ima RETURN - [%s]", get_name(fun_indeks_pomocna));
      else
      {
      	if(get_type(fun_indeks_pomocna) != get_type($2))
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

poziv_funkcije
  : ID
  	{
  		fun_poziv_pomocna = lookup_symbol($1, FUN);
  		if(fun_poziv_pomocna == NO_INDEX)
  			err("Funkcija koju ste pokusali da pozovete ne postoji - [%s]", $1);
  	}
  ZAGO argument ZAGZ
  	{
  		if(get_atr1(fun_poziv_pomocna) != $4)
  			err("Pogresan broj argumenata za pozvanu funkciju - [%s]", get_name(fun_poziv_pomocna));
  		set_type(FUN_REG, get_type(fun_poziv_pomocna));
  		$$ = FUN_REG;
  	}
  ;

argument
	: { $$ = 0; }
	| skup_izraza
		{
			if(get_atr2(fun_poziv_pomocna) != get_type($1))
				err("Pogresan tip argumenta za funkciju - [%s]", get_name(fun_poziv_pomocna));
			$$ = 1;
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

int main() 
{ 
  int FATALNA_GRESKA;
  init_symtab();

  FATALNA_GRESKA = yyparse();

  clear_symtab();

  if(broj_gresaka)
    printf("\n Broj GRESAKA: [%d] \n", broj_gresaka);

  if(broj_upozorenja)
    printf("\n Broj UPOZORENJA: [%d] \n", broj_upozorenja);

  if(FATALNA_GRESKA)
    return -1;
  else
    return broj_gresaka;

  yyparse(); 
}