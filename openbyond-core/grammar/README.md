# OpenBYOND DM Syntax

*FOR THE LOVE OF GOD, DON'T TOUCH THIS UNLESS YOU KNOW WHAT YOU'RE DOING!*

This directory contains the files specifying how DMScript is parsed by OpenBYOND.

## tokens.l

Contains instructions on how code is broken up into tokens.  Flex reads this.

## parser.y

Tells OpenBYOND how DMScript is structured, given the tokens above.  Bison uses this.