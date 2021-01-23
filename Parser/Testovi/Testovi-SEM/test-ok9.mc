--OPIS: testiranje individualnog zadatka 2, obicno i ugnjezdeno
Fun .ceo Main << >> 
(

	.ceo A = 0;
	.ceo C = 5;
	.ceo B = 2;
	.ceo D = 5;

	do loop 
    (
        A .inkr;
    )
    end
    while (C > B);

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

    .vrati 0;
)
