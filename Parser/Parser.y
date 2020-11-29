  %{
  #include <stdio.h>

  int yylex(void);
  int yyparse(void);
  int yyerror(char *err);
  extern int yylineno;
%}

%token FUN
%token F_ZAGO
%token F_ZAGZ

%token ZAGO
%token ZAGZ

%token SEPARATOR_ZAREZ
%token SEPARATOR_TACKA_ZAREZ

%token TIP

%token BOOL
%token INT
%token U_INT
%token FLOAT

%token ID

%token ROP
%token AOP
%token DOP

%token INCR
%token DECR

%token IF
%token ELSE
%token IF_ZAGO
%token IF_ZAGZ

%token IZLZ

%%

program
  : lista_funkcija
  ; 

lista_funkcija
  : funkcija
  | lista_funkcija funkcija
  ;

funkcija
  : TIP FUN ID F_ZAGO parametar F_ZAGZ telo
  ;

parametar
  : 
  | TIP ID
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
  : ID INCR SEPARATOR_TACKA_ZAREZ
  ;

dekrementacija
  : ID DECR SEPARATOR_TACKA_ZAREZ
  ;

dodela
  : ID DOP skup_izraza SEPARATOR_TACKA_ZAREZ
  ;

if_operacija
  : IF IF_ZAGO skup_rel_izraza IF_ZAGZ operacija
  ;

grupa_operacija
  : ZAGO lista_operacija ZAGZ
  ;

izlaz
  : IZLZ skup_izraza SEPARATOR_TACKA_ZAREZ
  ;

skup_rel_izraza
  : skup_izraza ROP skup_izraza
  ;

skup_izraza
  : izraz
  | skup_izraza AOP izraz
  ;

izraz
  : broj
  | ID
  | ID INCR
  | ID DECR
  | ZAGO skup_izraza ZAGZ
  ;

broj
  : INT
  | U_INT
  | FLOAT
  | BOOL
  ;

%%

int yyerror(char *err) 
{ 
  fprintf(stderr, "\n[LINIJA -> %d]: SINTAKSNA GRESKA [rec -> %s]\n", yylineno, err); return 0; 
} 

int main() 
{ 
  yyparse(); 
}

