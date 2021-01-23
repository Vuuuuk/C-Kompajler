//OPIS: inkrement u numexp-u
//RETURN: 53

.ceo Y;

Fun .ceo Main << >> 
(
    .ceo X;
    X = 2;
    Y = 6;
    Y = X.inkr + Y.inkr + 42;

    .vrati X + Y;
)
