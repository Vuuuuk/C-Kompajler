%{
  #include <stdio.h>
  int yylex(void);
  int yyparse(void);
  int yyerror(char *);
  extern int yylineno;
%}

%token FUN
%token SPACE
%token F_ZAGO
%token F_ZAGZ
%token ZAGO
%token ZAGZ
%token SEPARATOR
%token TIP
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
  : FUN SPACE ID SPACE F_ZAGO SPACE parametar SPACE F_ZAGZ SPACE telo
  ;

telo
  : ZAGO SPACE parametar SPACE ZAGZ 
  ;

parametar
  : 
  | TIP SPACE ID
  ;

%%

int main() { yyparse(); }

int yyerror(char *s) { fprintf(stderr, "\n[LINIJA -> %d]: SINTAKSNA GRESKA [rec -> %s]\n", yylineno, s); } 

