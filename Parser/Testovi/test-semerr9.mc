--OPIS: case tip konstanti mora biti isti kao tip promenjive 

Fun .ceo Main << >> 
(
	.ceo A = 2;

    check (A) 
    {
        case 1 : A .inkr; break;
        case 2u : A .inkr; break;
        case 3 : A .inkr; break;
        default : A .dekr; 
    }

    .vrati 0;
)

