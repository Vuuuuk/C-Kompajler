//OPIS: individualni zadatak ugnjezdeni do while
//RETURN: 8
Fun .ceo Main << >> 
(

	.ceo A = 0;
  .ceo B = 0;

	do loop 
    (

       do loop 
       (

          do loop 
          (
            A .inkr;
          )  
          end
          while (A != 8);

       )	
       end
       while (A != 8);

    )
    end
    while (A != 8);

    do loop 
    (
      B .inkr;
    )  
    end
    while (B != 8);

    .vrati A;
)
