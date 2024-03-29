%option noyywrap

%%

[\ \n\t]+
(--)[a-zA-Z0-9]*
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 

(Fun)   { printf("Kljucna_Rec_Fun\n"); }
(\<\<)  { printf("Zagrada_<<\n"); }
(\>\>)  { printf("Zagrada_>>\n"); }
\(      { printf("Zagrada_(\n"); }
\)      { printf("Zagrada_)\n"); }

\,	    { printf("Karakter_,)\n"); }
\;	    { printf("Karakter_;"); }

(bool)|(\.bool)			 { printf("Tip_Podataka_BOOL\n"); }
(int)|(\.ceo)            { printf("Tip_Podataka_INT\n"); }
(unsigned)|(\.uceo)      { printf("Tip_Podataka_UNSIGNED_INT\n"); }
(float)|(\.dec)		     { printf("Tip_Podataka_FLOAT\n"); }

(void)|(.bez_tipa)		 { printf("Tip_Funkcije_VOID\n"); }

(tacno)|(ntacno) 		 { printf("BROJ_TIPA_BOOL\n"); }
[0-9]{1,5}		       	 { printf("BROJ_TIPA_INT\n"); }
(uceo.)[0-9]{1,5}        { printf("BROJ_TIPA_UNSIGNED_INT\n"); }
[0-9]{1,5}(,)[0-9]{1,5}  { printf("BROJ_TIPA_DECIMAL\n"); }

[A-Z][a-zA-Z0-9]* { printf("Identifikator_Prepoznat\n"); }

(>)|(\.vece)            { printf("Relacioni_Operator_>\n"); }
(<)|(\.manje)           { printf("Relacioni_Operator_<\n"); }
(>=)|(=>)|(\.vecee)     { printf("Relacioni_Operator_>=\n"); }
(<=)|(=<)|(\.manjee)    { printf("Relacioni_Operator_<=\n"); }
(==)|(\.jednako)        { printf("Relacioni_Operator_==\n"); }
(!=)|(=!)|(\.razlicito) { printf("Relacioni_Operator_!=\n"); }
(\&)|(\.i)              { printf("Relacioni_Operator_&\n"); }
(\|)|(\.ili)            { printf("Relacioni_Operator_|\n"); }

(\+)|(\.dodaj)    		{ printf("Operator_+\n"); }
(\-)|(\.oduzmi)   		{ printf("Operator_-\n"); }
(\*)|(\.pomnozi)  		{ printf("Operator_*\n"); }
(\/)|(\.podeli)   		{ printf("Operator_/\n"); }
(\%)|(\.moduo)    		{ printf("Operator_moduo\n"); }
(\^)|(\.stepen)   		{ printf("Operator_^\n"); }

(\.inkr)		  		{ printf("Inkrement_++\n"); }
(\.dekr) 	     		 { printf("Dekrement_--\n"); }

(\=)|(\.upisi) 	  		{ printf("Dodela_=\n"); }


(\?)|(\.ako)      		{ printf("Kljucna_Rec_IF\n"); }
(\.ako_nije)	  		{ printf("Kljucna_Rec_ELSE\n"); }

(return)|(\.vrati)		{ printf("Kljucna_Rec_RETURN\n"); }

(\{)  { printf("Zagrada_{\n"); }
(\})  { printf("Zagrada_}\n"); }

%%

int main() { yylex(); }
