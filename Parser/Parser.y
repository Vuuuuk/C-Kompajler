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
%token SEPARATOR
%token TIP
%token BOOL
%token INT
%token U_INT
%token FLOAT
%token ID
%token ROP
%token AOP
%token DOP
%token IF
%token IF_ZAGO
%token IF_ZAGZ

%%

program
  : lista_funkcija
  ; 

lista_funkcija
  : funkcija
  | lista_funkcija funkcija
  ;

funkcija
  : FUN ID F_ZAGO parametar F_ZAGZ telo
  ;

telo
  : ZAGO parametar ZAGZ 
  ;

parametar
  : 
  | TIP ID
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

