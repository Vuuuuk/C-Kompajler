--OPIS: testiranje individualnog zadatka 3
Fun .ceo Main << >> 
(

	.ceo A = 1;

    check (A) 
    {
        case 1 : A .inkr; break;
        case 2 : A .inkr; break;
        case 3 : A .inkr; break;
        default : A .dekr; 
    }

    .vrati 0;

)
