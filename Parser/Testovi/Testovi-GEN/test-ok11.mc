//OPIS: Ugnjezdeni if
//RETURN: 4
Fun .ceo Main << >> 
(
	.ceo A = 1;
	.ceo B = 4;
	.ako (A < B)
	(
		A .inkr;
		.ako (A < B)
		(
			A .inkr;
		)
	)

	.ako (A < B)
		A .inkr;

    	.vrati A;
)
