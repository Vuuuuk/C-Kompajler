//Sanity check, ispred svake funkcije potrebno je navesti Fun
//Obavezno pocetno veliko slovo, takodje pocetno veliko slovo kod ID-a je obavezno
//Parametri se stavljaju pod << >>, telo funkcije ide u ( )
//Oznaka za jednolinijski komenar
/*Oznaka za pocetak i kraj viselinijskog komenatara*/

Fun .ceo F << .ceo X >> 
(
    .ceo Y = 0;             //moram dodeliti vrednost zbog individualnog zadatka 1
    .vrati X + 2 - Y;
)

Fun .uceo F2 << >> 
(
    .vrati 2u;
)

Fun .uceo FF << .uceo X >> 
(
    .uceo Y = 1u;           //moram dodeliti vrednost zbog individualnog zadatka 1
    .vrati X + F2() - Y;
)

Fun .ceo Main << >>
(

/*Zbog individualnog zadatka jedan promenjivama kojima do kraja funkcije (pre .vrati iskaza) nije dodeljena neka vrednost moramo to uraditi ovde kako bi test prosao*/

    .ceo A;
    .ceo B = 0;
    .ceo AA = 0;
    .ceo BB = 0;
    .ceo C = 0;
    .ceo D;
    .uceo U;
    .uceo W;
    .uceo UU;
    .uceo WW = 1u;

/*Testiranje nekih dodatnih operacija, funkcionalnosti za dodatne operacije jos nisu realizovane, bice dodate u konacnoj verziji*/ 

    A .inkr;
    A .dekr;
    A = B .pomnozi BB;
    A = A .dodaj BB;
    A = A .oduzmi BB;

    --Testiranje poziva funkcije
    A = F(3);

/*Takodje za relacione operacije su dodate i .vecee (vece ili jednako), .manjee (manje ili jednako), .jednako, .razlicito*/

/*Takodje ubacena je leksika za .i i .ili kako bi mogli da pravimo dodatne IF provere medjutim nikakve implementacije/provere nema, to cu uraditi u sledecoj verziji*/

    //IF iskaz sa else delom
    .ako (A < B)  
        A = 1;
    .ako_nije 
        A = -2;

    .ako (A .manje B)  
        A = 1;

    .ako (A .vece B)  
        A = 1;

    .ako (A .vecee B)  
        A = 1;

    .ako (A .manjee B)  
        A = 1;

    .ako (A .jednako B)  
        A = 1;

    .ako (A .razlicito B)  
        A = 1;

    .ako (A + C == B + D - 4) 
        A = 1;
    .ako_nije
        A = 2;

    .ako (U == W) 
    (   
        U = FF(1u);
        A = F(11);
    )
    .ako_nije 
    (
        W = 2u;
    )
    .ako (A + C == B - D - -4) 
    ( 
        A = 1;
    )
    .ako_nije
        A = 2;

    A = F(42);

    .ako (A + (AA-C) - D < B + (BB-A))    
        UU = W-U+UU;
    .ako_nije
        D = AA+BB-C;

    --IF iskaz bez else dela
    .ako (A < B)  
        A = 1;

    .ako (A + C == B - +4)    
        A = 1;


    //Individualni zadatak 2, ugnjezdeno
    do loop 
    (
        do loop
            (
                D .inkr;
                C .inkr;
            )
        end
        while (D != 20);
    )
    end
    while (C > B);

    //Individualni zadatak 2
    do loop 
    (
        A .inkr;
    )
    end
    while (C > B);

    //Individualni zadatak 3
    check (A) 
    {
        case 1 : A .inkr; break;
        case 2 : A .inkr; break;
        case 3 : A .inkr; break;
        default : A .dekr; 
    }

    .vrati 0; //moramo da dodamo neku povratnu vrednost na kraju funkcije koja nije VOID
)

