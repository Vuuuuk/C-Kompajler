%option noyywrap yylineno
%{
  #include <string.h>
  #include "defs.h"
  #include "Parser.tab.h"
%}

%%

[\ \n\t]+
\/\/.*             
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 

(Fun)   				 	{ return _FUN; }
(\<\<)  				 	{ return F_ZAGO; }
(\>\>)  				 	{ return F_ZAGZ; }
\(      				 	{ return ZAGO; }
\)      				 	{ return ZAGZ; }

\,     				 		{ return SEPARATOR_ZAREZ; }
\;      				 	{ return SEPARATOR_TACKA_ZAREZ; }

(bool)|(\.bool)			 	{ yylval.i = BOOL;  return TIP; }
(int)|(\.ceo) 			 	{ yylval.i = INT;   return TIP; }
(unsigned)|(\.uceo) 	 	{ yylval.i = UINT;  return TIP; }
(float)|(\.dec)	    	 	{ yylval.i = FLOAT; return TIP; }
(void)|(.bez_tipa)			{ yylval.i = VOID;  return TIP; }

(tacno)|(ntacno) 			{ yylval.s = strdup(yytext); return _BOOL; }
[+-]?[0-9]{1,5}		     	{ yylval.s = strdup(yytext); return _INT; }
[0-9]{1,5}[u]				{ yylval.s = strdup(yytext); 
							  yylval.s[yyleng-1] = 0;
                       		  return _U_INT; }
[0-9]{1,5}(,,)[0-9]{1,5}  	{ return _FLOAT; }

[A-Z][a-zA-Z0-9]*			{ yylval.s = strdup(yytext); return ID; }	

(>)|(\.vece)			 	{ yylval.i = GT;      return ROP; }	
(<)|(\.manje)			 	{ yylval.i = LT;      return ROP; }
(>=)|(=>)|(\.vecee)     	{ yylval.i = GE;      return ROP; }
(<=)|(=<)|(\.manjee)     	{ yylval.i = LE;      return ROP; }
(==)|(\.jednako)         	{ yylval.i = EQ;      return ROP; }
(!=)|(=!)|(\.razlicito)  	{ yylval.i = NE;      return ROP; }

(\+)|(\.dodaj)			 	{ yylval.i = ADD;   return AOP; }
(\-)|(\.oduzmi)				{ yylval.i = SUB;   return AOP; }
(\*)|(\.pomnozi)	     	{ yylval.i = MUL;   return AOP; }		 
(\/)|(\.podeli)			 	{ yylval.i = DIV;   return AOP; }

(\.inkr)					{ return INCR; }
(\.dekr) 	    			{ return DECR; }

(\=)|(\.upisi)			 	{ return DOP; }

(\.ako)			    		{ return IF; }
(\.ako_nije)				{ return ELSE; }

(\?)						{ return COND_IF; }

(return)|(\.vrati)			{ return IZLZ; }

(\{)						{ return IF_ZAGO; }	
(\})					 	{ return IF_ZAGZ; }

(do)						{ return DO; }
(loop)						{ return LOOP; }
(end)						{ return END; }	
(while)						{ return WHILE;}

(check)						{ return CHECK; }
(case)						{ return CASE; }
(:)							{ return SEPARATOR_DVE_TACKE; }
(break)						{ return BREAK; }
(default)					{ return DEFAULT; }


.	{ printf("\n[LINIJA -> %d]: LEKSICKA GRESKA [karakter -> %c]\n", yylineno, *yytext); }

%%