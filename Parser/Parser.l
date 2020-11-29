%option noyywrap yylineno
%{
  #include "Parser.tab.h"
%}

%%

[\ \n\t]+
(--)[^\n]*
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 

(Fun)   				 	{ return FUN; }
(\<\<)  				 	{ return F_ZAGO; }
(\>\>)  				 	{ return F_ZAGZ; }
\(      				 	{ return ZAGO; }
\)      				 	{ return ZAGZ; }

\,      				 	{ return SEPARATOR_ZAREZ; }
\;      				 	{ return SEPARATOR_TACKA_ZAREZ; }

(bool)|(\.bool)			 	{ return TIP; }
(int)|(\.ceo) 			 	{ return TIP; }
(unsigned)|(\.uceo) 	 	{ return TIP; }
(float)|(\.dec)	    	 	{ return TIP; }

(tacno)|(ntacno) 			{ return BOOL; }
[0-9]{1,5}		     		{ return INT; }
(uceo.)[0-9]{1,5}			{ return U_INT; }
[0-9]{1,5}(,)[0-9]{1,5}  	{ return FLOAT; }

[A-Z][a-zA-Z0-9]*		 	{ return ID; }	

(>)|(\.vece)			 	{ return ROP; }	
(<)|(\.manje)			 	{ return ROP; }
(>=)|(=>)|(\.vecee)     	{ return ROP; }
(<=)|(=<)|(\.manjee)     	{ return ROP; }
(==)|(\.jednako)         	{ return ROP; }
(!=)|(=!)|(\.razlicito)  	{ return ROP; }
(\&)|(\.i)				 	{ return ROP; }
(\|)|(\.ili)		     	{ return ROP; }

(\+)|(\.dodaj)			 	{ return AOP; }
(\-)|(\.oduzmi)				{ return AOP; }
(\*)|(\.pomnozi)	     	{ return AOP; }		 
(\/)|(\.podeli)			 	{ return AOP; }
(\%)|(\.moduo)			 	{ return AOP; }
(\^)|(\.stepen)			 	{ return AOP; }

(\.inkr)					{ return INCR; }
(\.dekr) 	    			{ return DECR; }

(\=)|(\.upisi)			 	{ return DOP; }
(\.ispis)				 	{ return DOP; }

(\?)|(\.ako)			    { return IF; }
(\.ako_nije)				{ return ELSE; }

(return)|(\.vrati)			{ return IZLZ; }

(\{)						{ return IF_ZAGO; }	
(\})					 	{ return IF_ZAGZ; }



. { printf("\n[LINIJA -> %d]: LEKSICKA GRESKA [karakter -> %c]\n", yylineno, *yytext); }    

