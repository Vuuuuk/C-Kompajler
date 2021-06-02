//OPIS: Poziv funkcije sa vise parametara i povratna vrednost
//RETURN: 3
Fun .ceo T1 << .ceo A, .ceo B, .ceo C, .ceo J, .ceo E>>
(
	.ceo D;
	D = E;
	.vrati D;
)
Fun .ceo Main << >> 
(
    .ceo A;
    A = T1(1, 1, 1, 1, 3);
    .vrati A;
)