#ifndef DEFS_H
#define DEFS_H

#define bool int
#define TRUE  1
#define FALSE 0

#define SYMBOL_TABLE_LENGTH   64
#define NO_INDEX              -1
#define NO_ATR                 0
#define LAST_WORKING_REG      12
#define FUN_REG               13
#define CHAR_BUFFER_LENGTH   128


extern char char_buffer[CHAR_BUFFER_LENGTH];

//ISPIS
extern void warning(char *s);
extern int yyerror(char *s);
//ISPIS

#define err(args...)  sprintf(char_buffer, args), \
                      yyerror(char_buffer)
#define warn(args...) sprintf(char_buffer, args), \
                      warning(char_buffer)

//TIPOVI
enum tipovi_promenjivih { NO_TYPE, INT, UINT, BOOL, FLOAT };

//vrste simbola (moze ih biti maksimalno 32)
enum kinds { NO_KIND = 0x1, REG = 0x2, LIT = 0x4, 
             FUN = 0x8, VAR = 0x10, PAR = 0x20 };

//OPERATORI_DODELE
enum dodela_operatori 	   { UPISI, ISPISI, DOP_BROJ };

//ARITMETICKI_OPERATORI
enum aritmeticki_operatori { DODAJ, ODUZMI, POMNOZI, PODELI, MODUO, STEPEN, 
						     AOP_BROJ };

//RELACIONI_OPERATORI
enum relacioni_operatori   { VECE, MANJE, VECEE, MANJEE, JEDNAKO, RAZLICITO, 
						   	 I, ILI, ROP_BROJ };

#endif

