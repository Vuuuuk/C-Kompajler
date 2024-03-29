
#ifndef SYMTAB_H
#define SYMTAB_H

// Element tabele simbola
typedef struct sym_entry {
   char *   name;          // ime simbola
   unsigned kind;          // vrsta simbola
   unsigned type;          // tip vrednosti simbola
   unsigned atr1;          // BROJ INT-ova
   unsigned atr2;          // TIP - INT
   unsigned atr3;		   // BROJ UINT-ova
   unsigned atr4;		   // TIP - UINT
} SYMBOL_ENTRY;

// Vraca indeks prvog sledeceg praznog elementa.
int get_next_empty_element(void);

// Vraca indeks poslednjeg zauzetog elementa.
int get_last_element(void);

// Ubacuje novi simbol (jedan red u tabeli) 
// i vraca indeks ubacenog elementa u tabeli simbola 
// ili -1 u slucaju da nema slobodnog elementa u tabeli.
int insert_symbol(char *name, unsigned kind, unsigned type, 
                  unsigned atr1, unsigned atr2, unsigned atr3, unsigned atr4);

// Ubacuje konstantu u tabelu simbola (ako vec ne postoji).
int insert_literal(char *str, unsigned type);

// Vraca indeks pronadjenog simbola ili vraca -1.
int lookup_symbol(char *name, unsigned kind);

// set i get metode za polja tabele simbola
void     set_name(int index, char *name);
char*    get_name(int index);
void     set_kind(int index, unsigned kind);
unsigned get_kind(int index);
void     set_type(int index, unsigned type);
unsigned get_type(int index);
void     set_atr1(int index, unsigned atr1);
unsigned get_atr1(int index);
void     set_atr2(int index, unsigned atr2);
unsigned get_atr2(int index);
void     set_atr3(int index, unsigned atr3); //dodavanje u atr3
unsigned get_atr3(int index);
void     set_atr4(int index, unsigned atr4); //dodavanje u atr4
unsigned get_atr4(int index);

// Brise elemente tabele od zadatog indeksa
void clear_symbols(unsigned begin_index);

// Brise sve elemente tabele simbola.
void clear_symtab(void);

// Ispisuje sve elemente tabele simbola.
void print_symtab(void);
unsigned logarithm2(unsigned value);

// Inicijalizacija tabele simbola.
void init_symtab(void);

#endif
