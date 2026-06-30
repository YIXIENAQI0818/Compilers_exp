%option noyywrap
%{

#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"


%}

digit [0-9]

%%


{digit}* { 
    return INT;
}

\+ {
    return ADD;
}

. {
    return ELSE;
}

%%