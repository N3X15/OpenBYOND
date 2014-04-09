/atom
	proc
		who_cares(var/datum/butts)
			return 5

/* Some  stuff
Other stuff
*/
/* More stuff */
// Single line comment

///* 
#ifdef USE_WHO_CARES
// Using who_cares
/atom/atom2/who_cares(var/datum/butts)
	return "Yep"
#else
// Not using who_cares
/atom/atom2/who_cares(var/datum/butts)
	return "Nope"
#endif
//*/