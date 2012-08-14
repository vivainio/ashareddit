/**
 * Select CSS file based on screen width
 */
if (window.innerWidth > 240) {
	document.write('<link rel="stylesheet" href="s40-theme/css/single_landscape.css" type="text/css" />');
}
else {
	document.write('<link rel="stylesheet" href="s40-theme/css/single_portrait.css" type="text/css" />');
}
