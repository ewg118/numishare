/************************************
VISUALIZATION FUNCTIONS
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: Rendering graphics based on hoard counts
************************************/
$(document).ready(function () {
	var langStr = getURLParameter('lang');
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}
	
	function getURLParameter(name) {
		return decodeURI(
		    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
		);
	}
	
	var pipeline = $('#pipeline').text();
	
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
	
	/********** TYPOLOGY VISUALIZATION ************/
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
	
	/********************* SPARQL-BASED FACETS ***********************/	
	$('.sparql_facets') .livequery('change', function(event){
		var field = $(this) .children("option:selected") .val();
		var container = $(this) .parent('.searchItemTemplate') .children('.option_container');
		
		//date
		if (field == 'date') {
			var tpl = $('#dateTemplate') .clone();		
			//remove id to avoid duplication with the template
			tpl.removeAttr('id');
			container.html(tpl);
		} 
		//sparql-based facets
		else {
			$.get(pipeline + 'widget', {
				field: field, lang: lang, template: 'facets'
			}, function (data) {
				container.html(data);
			});
		}
	});
	
	$('.measurementTable').each(function () {
		var units = $('#measurementUnits').text();
		var table = $(this),
		options = {
			chart: {
				renderTo: 'weight-container',
				type: getURLParameter('chartType')
			},
			title: {
				text: $(this).children('caption').text()
			},
			legend: {
				enabled: true
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
					text: $(this).children('caption').text() + (units.length > 0 ? ' (' + units + ')' : '')
				}
			},
			tooltip: {
				formatter: function () {					
					return this.y + ' ' + units;
				}
			},
			exporting: {
				enabled: true,
				width: 1200
			},
		};
		Highcharts.visualize(table, options);
	});
	
	$('#submit-measurements').click(function () {
		var selection = new Array();
		$('.weight-checkbox:checked').each(function(){
			selection.push($(this).val());
		});
		$('.customSparqlQuery .mr').each(function(){
			selection.push($(this).text());
		});
		//set sparqlQuery
		var q = selection.join('|');
		$('#sparqlQuery').attr('value', q);
		
		//process interval/duration
		if ($(this).closest('form').find('.from_date') .val().length > 0 && $(this).closest('form').find('.to_date') .val().length > 0 && $(this).closest('form').find('select[name=interval]') .val().length > 0){
			var fromDate = ($(this).closest('form').find('.from_era') .val() == 'minus' ? '-' : '') + Math.abs($(this).closest('form').find('.from_date') .val());
			var toDate = ($(this).closest('form').find('.to_era') .val() == 'minus' ? '-' : '') + Math.abs($(this).closest('form').find('.to_date') .val());
			
			//set values
			$(this).closest('form').find('.from_date').attr('value', fromDate);
			$(this).closest('form').find('.to_date').attr('value', toDate);
		}
	});
	
	$('#addSparqlQuery').fancybox();
	
	/****** SUBMITTING FORM ******/
	//filter button activation
	$('#sparqlForm').submit(function () {
		var q = assembleSparqlQuery('sparqlForm');
		var label = assembleSparqlLabel('sparqlForm');
		
		//create human and machine readable spans
		var hr = '<span class="hr">' + label + '</span>';
		var mr = '<span class="mr">' + q + '</span>';
		
		//insert new query
		var newQuery = '<div class="customSparqlQuery"><b>Query: </b>' + hr + mr + '<a href="#" class="removeQuery">Remove Query</a></div>';
		$('#customSparqlQueryDiv').append(newQuery);
			
		//close fancybox
		$.fancybox.close();
		
		//clear searchBox for next addition
		$('#sparqlInputContainer').empty();
		
		//reset template
		var tpl = cloneTemplate('sparqlForm');
		$('#sparqlInputContainer') .html(tpl);
		
		// display the entire new template
		tpl.fadeIn('fast');
		
		return false;
	});
	/***** VALIDATION *****/
	//lock bar and column charts for count in date visualization--line, spine, area, and areaspline for percentages
	$('#charts-form select[name=interval]').change(function () {
		validateForm();	
	});
	$('#charts-form input[name=fromDate]').change(function () {
		validateForm();	
	});
	$('#charts-form input[name=toDate]').change(function () {
		validateForm();	
	});
	$('#charts-form .from_era').change(function () {
		validateForm();	
	});
	$('#charts-form .to_era').change(function () {
		validateForm();	
	});
	
	function validateForm(){
		if ($('#charts-form select[name=interval]').val()  > 0 && $('#charts-form input[name=fromDate]').val() > 0 && $('#charts-form input[name=toDate]').val() > 0 ) {
			//enable linear options
			$('#charts-form').find('input[value=line]').attr('disabled', false);
			$('#charts-form').find('input[value=area]').attr('disabled', false);
			$('#charts-form').find('input[value=spline]').attr('disabled', false);
			$('#charts-form').find('input[value=areaspline]').attr('disabled', false);
			//make sure toDate is greater than fromDate
			var from_era = $('#charts-form .from_era') .val() == 'minus' ? -1 : 1;
			var to_era = $('#charts-form .to_era') .val() == 'minus' ? -1 : 1;
			
			var fromDate = Math.abs($('#charts-form input[name=fromDate]').val()) * from_era;
			var toDate = Math.abs($('#charts-form input[name=toDate]').val()) * to_era;
			if (toDate > fromDate){
				//enable submit/hide error		
				$('#charts-form input[type=submit]').attr('disabled', false);
				$('#measurement-alert').hide();
			} else {
				//disable submit/show error
				$('#charts-form input[type=submit]').attr('disabled', true);
				$('#validationError').text($('#visualize_error2').text());
				$('#measurement-alert').show();	
			}			
		} else if ($('#charts-form select[name=interval]').val().length == 0 && $('#charts-form input[name=fromDate]').val().length == 0 && $('#charts-form input[name=toDate]').val().length == 0) {
			//enable submit
			$('#charts-form input[type=submit]').attr('disabled', false);
			$('#measurement-alert').hide();
		} else {
			$('#charts-form').find('input[value=line]').attr('disabled', true);
			$('#charts-form').find('input[value=area]').attr('disabled', true);
			$('#charts-form').find('input[value=spline]').attr('disabled', true);
			$('#charts-form').find('input[value=areaspline]').attr('disabled', true);			
			//disable submit
			$('#charts-form input[type=submit]').attr('disabled', true);
			//show error
			$('#validationError').text($('#visualize_error1').text());
			$('#measurement-alert').show();		
		}
	}
	
	function assembleSparqlQuery(formId){
		var query = new Array();
		$('#' + formId + ' .searchItemTemplate') .each(function () {
			var field = $(this) .children('.sparql_facets') .val();
			var selectVar = $(this) .children('.option_container') .children('.search_text') .val();
			var fromDate = Math.abs($(this).find('.from_date') .val());
			var toDate = Math.abs($(this).find('.to_date') .val());
			
			if ((field != 'date' && field != '') && selectVar.length > 0) {
				query.push (field + ' &lt;' + selectVar + '&gt;');
			} else if (field == 'date' && Math.floor(fromDate) == fromDate && Math.floor(toDate) == toDate){
				var string = 'nm:end_date ?date';
				var from_era = $(this).find('.from_era') .val() == 'minus' ? '-' : '';
				var to_era = $(this).find('.to_era') .val() == 'minus' ? '-' : '';
				fromDate = from_era + pad(fromDate, 4);
				toDate = to_era + pad(toDate, 4);
				
				//create gYear compliant format from year integers
				string += ' FILTER ( ?date >= "' + fromDate +'"^^xs:gYear \\\\and ?date <= "' + toDate + '"^^xs:gYear )';
				query.push(string);
			}
		});
		q = query.join(' AND ');
		return q;
	}
	
	function assembleSparqlLabel(formId){
		var query = new Array();
		$('#' + formId + ' .searchItemTemplate') .each(function () {
			var selectVar = $(this) .children('.option_container') .children('.search_text') .val();
			var field = $(this) .children('.sparql_facets') .val();
			var fromDate = Math.abs($(this).find('.from_date') .val());
			var toDate = Math.abs($(this).find('.to_date') .val());
			
			if ((field != 'date' && field != '') && selectVar.length > 0) {	
				var termLabel = $(this) .children('.option_container').find('option:selected') .text();
				query.push(termLabel);
			}  else if (field == 'date' && Math.floor(fromDate) == fromDate && Math.floor(toDate) == toDate){
				var from_era = $(this).find('.from_era') .children('option:selected').text();
				var to_era = $(this).find('.to_era') .children('option:selected').text();				
				query.push(fromDate + ' ' + from_era + '-' + toDate + ' ' + to_era);
			}
		});
		label = query.join ('/');
		return label;
	}
	
	function pad(n, width, z) {
		z = z || '0';
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
	}
});

