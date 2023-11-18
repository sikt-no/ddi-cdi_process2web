$(document).ready(function() {
	// set logo link to external page
	$("p.logo > a").each(function(){
		$(this).attr('href', 'https://www.europeansocialsurvey.org/');
	});
	// set target to _blank for a link in div class target-blank
	$("div.target-blank a").each(function(){
		$(this).attr('target', '_blank');
	});
	// add tool tips to internal references
	// definition is in additional description.js
	$("a.reference.internal").each(function(){
		// strip html file extension, strip leading '/' (Sikt server issue 2023-11-03)
		var term = $(this).attr('href').replace(/\.html/, '').replace(/^\//, '');
//		var term = $(this).attr('href').replace(/\.html/, '');
		tooltip = description[term];
		if (tooltip != undefined) {
			$(this).attr('title', tooltip);
		}
	});
});
