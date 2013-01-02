$(function () {
	$(".ui-menubar-link").hover(
	function () {
		$(this).addClass("ui-state-hover");
		$(this).addClass("ui-state-focus");
	},
	function () {
		$(this).removeClass("ui-state-hover");
		$(this).removeClass("ui-state-focus");
	});
});