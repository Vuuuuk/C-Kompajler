%option noyywrap yylineno
%{
  #include <string.h>
  #include "defs.h"
  #include "Parser.tab.h"
%}

%%

[\ \n\t]+
(--)[^\n]*
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 

(Fun)   				 	{ return _FUN; }
(\<\<)  				 	{ return F_ZAGO; }
(\>\>)  				 	{ return F_ZAGZ; }
\(      				 	{ return ZAGO; }
\)      				 	{ return ZAGZ; }

\,      				 	{ return SEPARATOR_ZAREZ; }
\;      				 	{ return SEPARATOR_TACKA_ZAREZ; }

(bool)|(\.bool)			 	{ yylval.i = BOOL;  return TIP; }
(int)|(\.ceo) 			 	{ yylval.i = INT;   return TIP; }
(unsigned)|(\.uceo) 	 	{ yylval.i = UINT;  return TIP; }
(float)|(\.dec)	    	 	{ yylval.i = FLOAT; return TIP; }
(void)|(.bez_tipa)			{ yylval.i = VOID;  return TIP; }

(tacno)|(ntacno) 			{ yylval.s = strdup(yytext); return _BOOL; }
[0-9]{1,5}		     		{ yylval.s = strdup(yytext); return _INT; }
(uceo.)[0-9]{1,5}			{ yylval.s = strdup(yytext); 
                       		  yylval.s[0] = 0;
                       		  yylval.s[1] = 0;
                       		  yylval.s[2] = 0;
                       		  yylval.s[3] = 0;
                       		  yylval.s[4] = 0;   		 return _U_INT; }
[0-9]{1,5}(,)[0-9]{1,5}  	{ return _FLOAT; }

[A-Z][a-zA-Z0-9]*		 	{ yylval.s = strdup(yytext); return ID; }	

(>)|(\.vece)			 	{ yylval.i = VECE;      return ROP; }	
(<)|(\.manje)			 	{ yylval.i = MANJE;     return ROP; }
(>=)|(=>)|(\.vecee)     	{ yylval.i = VECEE;     return ROP; }
(<=)|(=<)|(\.manjee)     	{ yylval.i = MANJEE;    return ROP; }
(==)|(\.jednako)         	{ yylval.i = JEDNAKO;   return ROP; }
(!=)|(=!)|(\.razlicito)  	{ yylval.i = RAZLICITO; return ROP; }
(\&)|(\.i)				 	{ yylval.i = I; 	    return ROP; }
(\|)|(\.ili)		     	{ yylval.i = ILI; 	    return ROP; }

(\+)|(\.dodaj)			 	{ yylval.i = DODAJ;   return AOP; }
(\-)|(\.oduzmi)				{ yylval.i = ODUZMI;  return AOP; }
(\*)|(\.pomnozi)	     	{ yylval.i = POMNOZI; return AOP; }		 
(\/)|(\.podeli)			 	{ yylval.i = PODELI;  return AOP; }
(\%)|(\.moduo)			 	{ yylval.i = MODUO;   return AOP; }
(\^)|(\.stepen)			 	{ yylval.i = STEPEN;  return AOP; }

(\.inkr)					{ return INCR; }
(\.dekr) 	    			{ return DECR; }

(\=)|(\.upisi)			 	{ return DOP; }

(\?)|(\.ako)			    { return IF; }
(\.ako_nije)				{ return ELSE; }

(return)|(\.vrati)			{ return IZLZ; }

(\{)						{ return IF_ZAGO; }	
(\})					 	{ return IF_ZAGZ; }



. { printf("\n[LINIJA -> %d]: LEKSICKA GRESKA [karakter -> %c]\n", yylineno, *yytext); }    

