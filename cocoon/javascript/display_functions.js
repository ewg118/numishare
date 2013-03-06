/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	$('a.thumbImage').fancybox();
	
	$("#tabs").tabs();
	//enable basic query form
	
	/**
	* Visualize an HTML table using Highcharts. The top (horizontal) header
	* is used for series names, and the left (vertical) header is used
	* for category names. This function is based on jQuery.
	* @param {Object} table The reference to the HTML table to visualize
	* @param {Object} options Highcharts options
	*/
	Highcharts.visualize = function (table, options) {
		// the categories
		options.xAxis.categories =[];
		$('tbody th', table).each(function (i) {
			options.xAxis.categories.push(this.innerHTML);
		});
		
		// the data series
		options.series =[];
		$('tr', table).each(function (i) {
			var tr = this;
			$('th, td', tr).each(function (j) {
				if (j > 0) {
					// skip first column
					if (i == 0) {
						// get the name and init the series
						options.series[j - 1] = {
							name: this.innerHTML,
							data:[]
						};
					} else {
						// add values
						options.series[j - 1].data.push(parseFloat(this.innerHTML));
					}
				}
			});
		});
		
		var chart = new Highcharts.Chart(options);
	}
	
	$('.calculate').each(function () {
		var id = $(this).attr('id').split('-')[0];
		var table = $(this),
		options = {
			chart: {
				renderTo: id + '-container',
				type: getURLParameter('type'),
				width: 916
			},
			title: {
				text: $(this).children('caption').text()
			},
			legend: {
				enabled: false
			},
			xAxis: {
				labels: {
					rotation: -45,
					align: 'right',
					style: {
						fontSize: '11px',
						fontFamily: 'Verdana, sans-serif'
					}
				}
			},
			yAxis: {
				title: {
					text: 'Weight'
				}
			},
			tooltip: {
				formatter: function () {					
					return this.y + ' grams';
				}
			},
			exporting: {
				enabled: true,
				width: 1200
			},
		};
		Highcharts.visualize(table, options);
	});
	
	function getURLParameter(name) {
    		return decodeURI(
        			(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    		);
	}
	
	$('#submit-weights').click(function () {
		var selection = new Array();
		$('.weight-checkbox:checked').each(function(){
			selection.push($(this).val());
		});
		var q = selection.join(' AND ');
		$('#weights-q').attr('value', q);
	});
})