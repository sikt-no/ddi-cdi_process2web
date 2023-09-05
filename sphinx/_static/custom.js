$(document).ready(function() {
	// set logo link to external page
	$("p.logo > a").each(function(){
		$(this).attr('href', 'https://www.europeansocialsurvey.org/');
	});
	// add tool tips to internal references
	// definition is in additional description.js
	$("a.reference.internal").each(function(){
		// strip html file extension
		var term = $(this).attr('href').replace(/\.html/, '');
		tooltip = description[term];
		if (tooltip != undefined) {
			$(this).attr('title', tooltip);
		}
	});
})(window, document, jQuery);
