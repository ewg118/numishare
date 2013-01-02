$(document).ready (function () {
	$.get('feature_count', {},
	function (data) {
		//convert total count to an integer
		var count = Number(data);			
		var seed = Math.floor(Math.random() * count);	
		$.get('get_feature', {
			seed: seed
		},
		function (data) {
			$('#feature') .append(data);			
		});
	});
});