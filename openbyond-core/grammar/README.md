# OpenBYOND DM Syntax

*FOR THE LOVE OF GOD, DON'T TOUCH THIS UNLESS YOU KNOW WHAT YOU'RE DOING!*

This directory contains the files specifying how DMScript is parsed by OpenBYOND.  The grammar was originally written 
by Jp <http://www.byond.com/members/Jp?command=view_post&post=95192&first_unread=1>, but has been extended to be more robust and cover more edge
cases.

(Note: I originally accidentally credited this to nan0desu.  This has been corrected.)

## tokens.l

Contains instructions on how code is broken up into tokens.  Flex reads this and feeds it to bison.

## parser.y

Tells OpenBYOND how DMScript is structured, given the tokens above.  Bison uses this.