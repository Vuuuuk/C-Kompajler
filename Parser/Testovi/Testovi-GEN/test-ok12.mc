//OPIS: Dodatni zadatak 3 check naredba
//RETURN:40
Fun .ceo Main << >> 
(

	.ceo A = 2;

    check (A) 
    {
        case 1 : A = 10; break;
        case 3 : A = 20; 
        case 4 : A = 30; break;
        default: A = 40; 
    }

    .vrati A;

)
