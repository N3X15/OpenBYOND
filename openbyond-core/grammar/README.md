# OpenBYOND DM Syntax

*FOR THE LOVE OF GOD, DON'T TOUCH THIS UNLESS YOU KNOW WHAT YOU'RE DOING!*

This directory contains the files specifying how DMScript is parsed by OpenBYOND.  The grammar was originally written 
by nan0desu (

## tokens.l

Contains instructions on how code is broken up into tokens.  Flex reads this and feeds it to bison.

## parser.y

Tells OpenBYOND how DMScript is structured, given the tokens above.  Bison uses this.