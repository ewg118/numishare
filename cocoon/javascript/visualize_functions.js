/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
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
		var type = $('input:radio[name=type]:checked').val();
		var chartType = $('input:radio[name=chartType]:checked').val();
		var optionString = $('#options-input').val();
		if (chartType == 'bar') {
			var height = 800;
		} else {
			var height = 400;
		}
		
		var options = processOptions(optionString);
		
		var table = $(this),
		options = {
			chart: {
				renderTo: id + '-container',
				type: chartType,
				height: height
			},
			title: {
				text: $(this).children('caption').text()
			},
			legend: {
				enabled: true
			},
			xAxis: {
				labels: {
					rotation: - 45,
					align: 'right',
					style: {
						fontSize: '11px',
						fontFamily: 'Verdana, sans-serif'
					}
				}
			},
			yAxis: {
				max: (type == 'count'? null: 100),
				min: (type == 'count'? null: 0),
				title: {
					text: (type == 'percentage'? 'Percentage': 'Occurrences')
				}
			},
			tooltip: {
				formatter: function () {
					return this.y + (type == 'percentage'? '%: ': ' coin(s): ') + this.x;
				}
			},
			plotOptions: {
				series: {
					stacking: (type == 'count' ? options.stacking : null)					
				}
			}
		};
		Highcharts.visualize(table, options);
	});
	
	function processOptions(optionString) {
		var options = {};
		var result = optionString.split('|');
		for (i = 0; i < result.length; i++) {
			var key = result[i].split(':')[0];
			var value = result[i].split(':')[1];
			options[key] = value;
		}
		return options;
	}
	
	$('#submit-calculate').click(function () {
		//set the calculate input
		var checks = new Array();
		$('.calculate-checkbox:checked').each(function () {
			checks.push($(this).val());
		});
		var calculate = checks.join('|');
		$('#calculate-input').attr('value', calculate);
		
		//set the custom input
		customs = new Array();
		$('.customQuery').each(function () {
			customs.push($(this).children('span').text());
		});
		var custom = customs.join('|');
		$('#custom-input').attr('value', custom);
		
		//set compare input
		compares = new Array();
		$('.compareQuery').each(function () {
			compares.push($(this).children('span').text());
		});
		
		//assemble comparative queries if available, set *:* as default
		if (compares.length > 0) {
			var compare = compares.join('|');
		} else {
			var compare = '*:*';
		}
		$('#compare-input').attr('value', compare);
		
		//assemble options
		optionsArray = new Array();
		$('.optional-div option:selected').each(function () {
			optionsArray.push($(this).val());
		});
		var options = optionsArray.join('|');
		$('#options-input').attr('value', options);
	});
	
	/********* COMPARE/CUSTOMQUERY FUNCTIONS **********/
	//add customQuery
	$(".addQuery").click(function () {
		var href = $(this).attr('href');
		var id = $(this).attr('id');
		
		//set paramName
		$('#paramName').html(id);
		
		//load fancybox
		$.fancybox({
			'href': href
		});
		return false;
	});
	
	//filter button activation
	$('#advancedSearchForm').submit(function () {
		var q = assembleQuery('advancedSearchForm');
		var param = $('#paramName').text();
		
		//insert new query
		if (param == 'customQuery') {
			var newQuery = '<div class="customQuery"><b>Custom Query: </b><span>' + q + '</span><a href="#" class="removeQuery">Remove Query</a></div>'
			$('#' + param + 'Div').append(newQuery);
		} else if (param == 'compareQuery') {
			var newQuery = '<div class="compareQuery"><b>Comparison Query: </b><span>' + q + '</span><a href="#" class="removeQuery">Remove Query</a></div>'
			$('#' + param + 'Div').append(newQuery);
		}
		//close fancybox
		$.fancybox.close();
		
		//clear searchBox for next addition
		$('#inputContainer').empty();
		
		//reset template
		var tpl = cloneTemplate();
		$('#inputContainer') .html(tpl);
		
		// display the entire new template
		tpl.fadeIn('fast');
		
		return false;
	});
	
	//remove comparison or custom queries
	$('.removeQuery').livequery('click', function () {
		$(this).parent('div').remove();
		return false;
	});
	
	/***** TOGGLE OPTIONAL SETTINGS *****/
	$('.optional-button').click(function () {
		var formId = $(this).attr('id').split('-')[0] + '-form';
		$('#' + formId + ' .optional-div').toggle('slow');
	});
})