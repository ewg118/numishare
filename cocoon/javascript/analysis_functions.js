/*******************
VISUALIZATION FUNCTIONS 
Author: Ethan Gruber
Modification Date: November 2012
Description: Functions used in the Hoard Display and Analyze pipelines
for manipulating forms and rendering tables in the form of highcharts
********************/

$(document).ready(function(){
	$("#tabs").tabs();

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
		var table = $(this),
		options = {
			chart: {
				renderTo: id + '-container',
				type: chartType,
				width: 880
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
				title: {
					text: (type == 'percentage'? 'Percentage': 'Occurrences')
				}
			},
			tooltip: {
				formatter: function () {
					return this.y + (type == 'percentage'? '%: ': ' coins: ') + this.x;
				}
			}
		};
		Highcharts.visualize(table, options);
	});
	
	//set max number of 4 hoards for comparison (5 shown in total)
	$("#visualize-form .compare-select").livequery('change', function (event) {
		if ($("#visualize-form .compare-option:selected").length > 4) {
			$("#submit-calculate").attr("disabled", "disabled");
		} else {
			$("#submit-calculate").removeAttr('disabled');
		}
	});
	
	$('.compare-button').click(function () {
		//display the compare multiselect list only if it hasn't already been generated
		var cd = $(this).parent().children('.compare-div');
		if (cd.html().indexOf('<option') < 0) {
			$.get('../get_hoards', { 
				q: '*' 
			},
			function (data) {
				cd.html(data);
			});
		}
		return false;
	});
	
	$('#submit-calculate').click(function () {
		//get calculate facets
		var facets = new Array();
		$('.calculate-checkbox:checked').each(function () {
			facets.push($(this).val());
		});
		var param1 = facets.join(',');
		$('#calculate-input').attr('value', param1);
		
		//get compare value
		var hoards = new Array();
		$('#visualize-form .compare-option:selected').each(function () {
			hoards.push($(this).val());
		});
		var param2 = hoards.join(',');
		$('#visualize-form .compare-input').attr('value', param2);
	});
	
	$('#submit-csv').click(function () {
		//get compare value
		var hoards = new Array();
		$('#csv-form .compare-option:selected').each(function () {
			hoards.push($(this).val());
		});
		var param2 = hoards.join(',');
		$('#csv-form .compare-input').attr('value', param2);
	});
	
	/********* FILTERING FUNCTIONS **********/	
	$("#showFilter").fancybox();
	
	// total options for advanced search - used for unique id's on dynamically created elements
	var total_options = 1;
	
	// the boolean (and/or) items. these are set when a new search criteria option is created
	var gate_items = {
	};
	
	// focus the text field after selecting the field to search on
	$('.searchItemTemplate select') .change(function () {
		$(this) .siblings('.search_text') .focus();
	})
	
	// assign the gate/boolean button click handler
	$('.gateTypeBtn') .click(function () {
		gateTypeBtnClick($(this), total_options, gate_items);
	})
	
	//filter button activation
	$('#advancedSearchForm').submit(function() {
		var q = assembleQuery('advancedSearchForm');
		$('.filter-div').children('span').html(q);
		$('.filter-div').show();		
		$.get('get_hoards', { 
				q: q 
			},
			function (data) {
				$('.compare-div').html(data);
			});
		$.fancybox.close();
		return false;
	});
	
	//remove filter
	$('.removeFilter').click(function(){
		$('.filter-div').hide();	
		$.get('get_hoards', { 
			q: '*' 
			},
			function (data) {
				$('.compare-div').html(data);
			});
		return false;
	})
})