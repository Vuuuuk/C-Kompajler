%option noyywrap yylineno
%{
  #include "Parser.tab.h"
%}

%%

[\ \n\t]+
(--)[a-zA-Z0-9]*
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 

(Fun)   				 	{ return FUN; }
(\<\<)  				 	{ return F_ZAGO; }
(\>\>)  				 	{ return F_ZAGZ; }
\(      				 	{ return ZAGO; }
\)      				 	{ return ZAGZ; }

\,      				 	{ return SEPARATOR; }
\;      				 	{ return SEPARATOR; }

(bool)|(\.bool)			 	{ return TIP; }
(int)|(\.ceo) 			 	{ return TIP; }
(unsigned)|(\.uceo) 	 	{ return TIP; }
(float)|(\.dec)	    	 	{ return TIP; }

(tacno)|(ntacno) 			{ return BOOL; }
[+-][0-9]{1,5}		     	{ return INT; }
[0-9]{1,5}				 	{ return U_INT; }
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

(\=)|(\.upisi)			 	{ return DOP; }
(\.ispis)				 	{ return DOP; }

(\?)					 	{ return DOP; }
(\{)						{ return IF_ZAGO; }	
(\})					 	{ return IF_ZAGZ; }



. { printf("\n[LINIJA -> %d]: LEKSICKA GRESKA [karakter -> %c]\n", yylineno, *yytext); }    

