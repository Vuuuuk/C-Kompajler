--OPIS: više deklaracija sa više promenljivih
Fun .ceo Main << >> 
(

-- U ovom testu moramo dodeliti vrednosti, zbog implementiranog individualnog zadatka 1


    .ceo A = 2;
    .ceo B;
    .ceo C,D,E,F;
    .uceo G;

-- Vrednosti se dodeljuju posle inicijalizacije, spadaju u drugi deo tela funkcije

    A = 0; --Vrednosti se mogu prepisati posle inicijalizacije
    B = A;
    C = A;
    D = A;
    E = A;
    F = A;
    G = 1u;

    .vrati 0;
)
