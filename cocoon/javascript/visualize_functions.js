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
			$.get('../widget', {
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
		$('.customSparqlQuery span').each(function(){
			selection.push($(this).text());
		});
		var q = selection.join('|');
		//alert(q);
		$('#sparqlQuery').attr('value', q);
		//return false;
	});
	
	/***** TOGGLING SPARQL FACET FORM*****/
	$('.gateTypeBtn') .livequery('click', function(event){
		gateTypeBtnClick($(this));
		return false;
	});
	
	// focus the text field after selecting the field to search on
	$('.searchItemTemplate select').livequery('change', function(event){
		$(this) .siblings('.search_text') .focus();
	});
	
	$('.removeBtn').livequery('click', function(event){
		// fade out the entire template
		$(this) .parent() .fadeOut('fast', function () {
			$(this) .remove();
		});
		return false;
	});
	
	// copy the base template
	function gateTypeBtnClick(btn) {
		//clone the template
		var tpl = cloneTemplate();
		
		// focus the text field after select
		$(tpl) .children('select') .change(function () {
			$(this) .siblings('input') .focus();
		});
		
		// add the new template to the dom
		$(btn) .parent() .after(tpl);
		
		tpl.children('.removeBtn').removeAttr('style');
		tpl.children('.removeBtn') .before(' |&nbsp;');
		
		// display the entire new template
		tpl.fadeIn('fast');
	}
	
	function cloneTemplate (){
		var tpl = $('#searchItemTemplate') .clone();
		
		//remove id to avoid duplication with the template
		tpl.removeAttr('id');
		
		return tpl;
	}
	
	$('#addSparqlQuery').fancybox();
	
	/****** SUBMITTING FORM ******/
	//filter button activation
	$('#sparqlForm').submit(function () {
		var q = assembleSparqlQuery('sparqlForm');
		
		//insert new query
		var newQuery = '<div class="customSparqlQuery"><b>Custom Query: </b><span>' + q + '</span><a href="#" class="removeQuery">Remove Query</a></div>';
		$('#customSparqlQueryDiv').append(newQuery);
			
		//close fancybox
		$.fancybox.close();
		
		//clear searchBox for next addition
		$('#sparqlInputContainer').empty();
		
		//reset template
		var tpl = cloneTemplate();
		$('#sparqlInputContainer') .html(tpl);
		
		// display the entire new template
		tpl.fadeIn('fast');
		
		return false;
	});
	
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
	
	function pad(n, width, z) {
		z = z || '0';
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
	}
});

