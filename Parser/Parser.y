%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"


  int yylex(void);
  int yyparse(void);
  int yyerror(char *error);
  void warning(char *warning);

  extern int yylineno;

  char char_buffer[CHAR_BUFFER_LENGTH];
  int broj_gresaka = 0;
  int broj_upozorenja = 0;
  int var_brojac = 0;
  int fun_indeks_pomocna = -1;
  int fcall_idx = -1;
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

%token IF
%token ELSE
%token IF_ZAGO
%token IF_ZAGZ

%token IZLZ

%type <i> skup_izraza 
%type <i> skup_rel_izraza 
%type <i> izraz 
%type <i> broj 
%type <i> parametar

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
  : TIP _FUN ID 
    {
      fun_indeks_pomocna = lookup_symbol($3, FUN);
      if(fun_indeks_pomocna == NO_INDEX)
        fun_indeks_pomocna = insert_symbol($3, FUN, $1, NO_ATR, NO_ATR);
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
      insert_symbol($2, PAR, $1, 1, NO_ATR);
      set_atr1(fun_indeks_pomocna, 1);
      set_atr2(fun_indeks_pomocna, $1);
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
  : TIP format SEPARATOR_TACKA_ZAREZ
    {
      if(lookup_symbol($2, VAR|PAR) == NO_INDEX)
        insert_symbol($2, VAR, $1, ++var_brojac, NO_ATR);
      else
        err("Promenjiva sa datim imenom vec postoji - [%s]", $2);
    }
  ;

format
  : ID
  | format SEPARATOR_ZAREZ ID 
  ;

lista_operacija
  : operacija
  | lista_operacija operacija
  ;

operacija
  : inkrementacija
  | dekrementacija
  | dodela
  | if_operacija
  | grupa_operacija
  | izlaz
  ;

inkrementacija
  : ID
      {
        int id_index = lookup_symbol($1, VAR|PAR);
        if(id_index == NO_INDEX)
          err("Nepostojeci ID, nemoguca inkrementacija - [%s]", $1);
      } 
    INCR SEPARATOR_TACKA_ZAREZ
  ;

dekrementacija
  : ID
      {
        int id_index = lookup_symbol($1, VAR|PAR);
        if(id_index == NO_INDEX)
          err("Nepostojeci ID, nemoguca dekrementacija - [%s]", $1);
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
  : IF IF_ZAGO skup_rel_izraza IF_ZAGZ operacija
  ;

grupa_operacija
  : ZAGO lista_operacija ZAGZ
  ;

izlaz
  : IZLZ skup_izraza SEPARATOR_TACKA_ZAREZ
    {
      if(get_type(fun_indeks_pomocna) != get_type($2))
        err("Razliciti tipovi, IZLAZ nije moguc");
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
        err("ID ne postoji - [%s]", $1);
    }
  | ID DECR
    {
      $$ = lookup_symbol($1, VAR|PAR);
      if($$ == NO_INDEX)
        err("ID ne postoji - [%s]", $1);
    }
  | ZAGO skup_izraza ZAGZ
    {
      $$ = $2;
    }
  ;

broj
  : _INT   { $$ = insert_literal($1, INT);   }
  | _U_INT { $$ = insert_literal($1, UINT);  }
  | _FLOAT { $$ = insert_literal($1, FLOAT); }
  | _BOOL  { $$ = insert_literal($1, BOOL);  }
  ;

%%

int yyerror(char *error) 
{ 
  fprintf(stderr, "\n[LINIJA -> %d]: SINTAKSNA GRESKA \n", yylineno, error); 
  broj_gresaka++;
  return 0; 
} 

void upozorenje(char *warning)
{
  fprintf(stderr, "\n[LINIJA -> %d]: UPOZORENJE \n", yylineno, warning);
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