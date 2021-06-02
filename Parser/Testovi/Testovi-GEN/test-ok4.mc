//OPIS: vise ifova
//RETURN: 7

.ceo Y;

Fun .ceo Main << >>
(
    .ceo X;
    X = 2;
    Y = 6;

    .ako (X.inkr == Y) 
      X = 2;

    .ako (X .manje Y.inkr)
      X = 0;
    return X + Y;
)

