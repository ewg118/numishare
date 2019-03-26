<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes=" #all" version="2.0">
	<xsl:variable name="type_series" select="//config/type_series"/>

	<!-- ************** MEASUREMENT FORM FOR COIN TYPE ANALYSIS ************** -->
	<xsl:template name="measurementForm">
		<xsl:variable name="action">
			<xsl:choose>
				<xsl:when test="$pipeline='visualize'">#measurements</xsl:when>
				<xsl:when test="$pipeline='display'">
					<xsl:value-of select="concat('./', $id, '#charts')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="measurements">axis,diameter,weight</xsl:variable>
		<xsl:variable name="chartTypes">
			<xsl:choose>
				<xsl:when test="$pipeline='display'">bar,column</xsl:when>
				<xsl:otherwise>bar,column,area,line,spline,areaspline</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string($sparqlQuery)">
			<xsl:call-template name="measurementTable"/>
		</xsl:if>
		<form id="measurementsForm" action="{$action}" style="margin:40px" method="get">
			<div class="row">
				<h3>1. <xsl:value-of select="numishare:normalizeLabel('visualize_select_measurement', $lang)"/></h3>
				<xsl:for-each select="tokenize($measurements, ',')">
					<div class="col-md-2">
						<input type="radio" name="measurement" value="{.}">
							<xsl:choose>
								<xsl:when test="$measurement = .">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:when test=". = 'weight' and not(string($measurement))">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
							</xsl:choose>
						</input>
						<label for="measurement-radio">
							<xsl:value-of select="numishare:regularize_node(., $lang)"/>
						</label>
					</div>
				</xsl:for-each>
			</div>
			<div class="row">
				<h3>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h3>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<div class="col-md-2">
						<input type="radio" name="chartType" value="{.}">
							<xsl:if test="$chartType = . or (.='column' and not(string($chartType)))">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<xsl:if test="not(number($duration)) and (.='line' or .='area' or .='areaspline' or .='spline')">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
						</input>
						<label for="chartType-radio">
							<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
						</label>
					</div>
				</xsl:for-each>
			</div>
			<xsl:choose>
				<xsl:when test="$pipeline='display'">
					<!-- create categories as a variable -->
					<xsl:variable name="typologicalCategories" as="element()*">
						<categories>
							<xsl:for-each
								select="//nuds:material[string(@xlink:href)]|//nuds:denomination[string(@xlink:href)]|//nuds:manufacture[string(@xlink:href)]|//nuds:persname[string(@xlink:href)]|//nuds:corpname[string(@xlink:href)]|//nuds:famname[string(@xlink:href)]|//nuds:geogname[string(@xlink:href)]">
								<xsl:sort select="local-name()"/>
								<xsl:variable name="href" select="@xlink:href"/>
								<xsl:variable name="value">
									<xsl:choose>
										<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
											<xsl:choose>
												<xsl:when test="string($rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang][1])">
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang][1]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en'][1]"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<!-- if there is no text value and it points to nomisma.org, grab the prefLabel -->
											<xsl:choose>
												<xsl:when test="not(string(normalize-space(.))) and contains($href, 'nomisma.org')">
													<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en'][1]"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="."/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="name">
									<xsl:choose>
										<xsl:when test="string(@xlink:role)">
											<xsl:value-of select="@xlink:role"/>
										</xsl:when>
										<xsl:when test="string(@type)">
											<xsl:value-of select="@type"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="local-name()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<category name="{$name}" href="{$href}" value="{$value}" query="{concat('nmo:has', upper-case(substring($name, 1, 1)), substring($name, 2), ' &lt;', $href, '&gt;')}"/>
							</xsl:for-each>
						</categories>
					</xsl:variable>
					<div class="row">
						<h3>3. <xsl:value-of select="numishare:normalizeLabel('visualize_compare_category', $lang)"/></h3>
						<!-- create checkboxes for available facets -->
						<xsl:for-each select="$typologicalCategories//category">
							<div class="col-md-2">
								<xsl:variable name="query_fragment" select="@query"/>
								<xsl:choose>
									<xsl:when test="boolean(index-of($tokenized_sparqlQuery, $query_fragment)) = true()">
										<input type="checkbox" id="{@name}-checkbox" checked="checked" value="{$query_fragment}" class="weight-checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" id="{@name}-checkbox" value="{$query_fragment}" class="weight-checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<label for="{@name}-checkbox">
									<xsl:value-of select="numishare:regularize_node(@name, $lang)"/>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="@value"/>
								</label>
							</div>
						</xsl:for-each>
					</div>
					<div id="customSparqlQueryDiv" class="row">
						<h3>
							<xsl:text>4. </xsl:text>
							<xsl:value-of select="numishare:normalizeLabel('visualize_add_queries', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#sparqlBox" id="addSparqlQuery">
									<span class="glyphicon glyphicon-plus"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_add_new', $lang)"/>
								</a>
							</small>
						</h3>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<xsl:variable name="val" select="."/>
							<xsl:if test="not($typologicalCategories//category[@query=$val])">
								<div class="customSparqlQuery">
									<b><xsl:value-of select="numishare:normalizeLabel('visualize_query', $lang)"/>: </b>
									<span class="hr">
										<xsl:call-template name="sparqlLabel"/>
									</span>
									<span class="mr">
										<xsl:value-of select="."/>
									</span>
									<a href="#" class="removeQuery">
										<span class="glyphicon glyphicon-remove"/>
										<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
									</a>
								</div>
							</xsl:if>
						</xsl:for-each>
					</div>
				</xsl:when>
				<xsl:when test="$pipeline='visualize'">
					<div id="customSparqlQueryDiv" class="row">
						<h3>
							<xsl:text>3. </xsl:text>
							<xsl:value-of select="numishare:normalizeLabel('visualize_add_queries', $lang)"/>
							<small style="margin-left:10px;">
								<a href="#sparqlBox" id="addSparqlQuery">
									<span class="glyphicon glyphicon-plus"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_add_new', $lang)"/>
								</a>
							</small>
						</h3>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<div class="customSparqlQuery">
								<b><xsl:value-of select="numishare:normalizeLabel('visualize_query', $lang)"/>: </b>
								<span class="hr">
									<xsl:call-template name="sparqlLabel"/>
								</span>
								<span class="mr">
									<xsl:value-of select="."/>
								</span>
								<a href="#" class="removeQuery">
									<span class="glyphicon glyphicon-remove"/>
									<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
								</a>
							</div>
						</xsl:for-each>
					</div>
				</xsl:when>
			</xsl:choose>
			<!-- only display duration in visualize page: doesn't work properly from coin type comparison -->
			<xsl:if test="$pipeline='visualize'">
				<div class="row">
					<div class="alert alert-danger alert-box" id="measurementsForm-alert" style="display:none">
						<span class="glyphicon glyphicon-warning-sign"/>
						<span class="validationError"/>
					</div>
					<h3>
						<xsl:choose>
							<xsl:when test="$pipeline='display'">5</xsl:when>
							<xsl:when test="$pipeline='visualize'">4</xsl:when>
						</xsl:choose>
						<xsl:text>. </xsl:text>
						<xsl:value-of select="numishare:normalizeLabel('visualize_arrange', $lang)"/>
					</h3>
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_interval', $lang)"/>
					</h4>
					<select name="interval" class="form-control">
						<option value="">
							<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
						</option>
						<option value="5">
							<xsl:if test="$interval='5'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>5</xsl:text>
						</option>
						<option value="10">
							<xsl:if test="$interval='10'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>10</xsl:text>
						</option>
						<option value="20">
							<xsl:if test="$interval='20'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>20</xsl:text>
						</option>
						<option value="25">
							<xsl:if test="$interval='25'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>25</xsl:text>
						</option>
						<option value="50">
							<xsl:if test="$interval='50'">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>50</xsl:text>
						</option>
					</select>
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_duration', $lang)"/>
					</h4>
					<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
					<xsl:text>:</xsl:text>
					<input type="text" class="from_date form-control" name="fromDate" value="{if (string($fromDate)) then abs(number($fromDate)) else ''}"/>
					<select class="from_era form-control">
						<option value="minus">
							<xsl:if test="number($fromDate) &lt; 0">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>B.C.</xsl:text>
						</option>
						<option value="">
							<xsl:if test="number($fromDate) &gt; 0 or not(string($fromDate))">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>A.D.</xsl:text>
						</option>
					</select>
					<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
					<xsl:text>: </xsl:text>
					<input type="text" class="to_date form-control" name="toDate" value="{if (string($toDate)) then abs(number($toDate)) else ''}"/>
					<select class="to_era form-control">
						<option value="minus">
							<xsl:if test="number($toDate) &lt; 0">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>B.C.</xsl:text>
						</option>
						<option value="">
							<xsl:if test="number($toDate) &gt; 0 or not(string($toDate))">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:text>A.D.</xsl:text>
						</option>
					</select>
				</div>
			</xsl:if>
			<input type="hidden" name="sparqlQuery" id="sparqlQuery" value=""/>
			<xsl:if test="string($langParam)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>
			<br/>
			<input type="submit" class="btn btn-default" value="{numishare:normalizeLabel('visualize_generate', $lang)}" id="submit-measurements"/>
		</form>
		<div style="display:none">
			<div id="sparqlBox" class="popupQuery">
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/>
				</h3>
				<p>
					<xsl:value-of select="numishare:normalizeLabel('visualize_add_query_desc', $lang)"/>
				</p>
				<xsl:call-template name="sparql_form"/>
			</div>
		</div>
		<!--errors -->
		<div style="display:none">
			<span>errors</span>
			<span id="visualize_error1">
				<xsl:value-of select="numishare:normalizeLabel('visualize_error1', $lang)"/>
			</span>
			<span id="visualize_error2">
				<xsl:value-of select="numishare:normalizeLabel('visualize_error2', $lang)"/>
			</span>
		</div>
		<div style="display:none">
			<span id="pipeline">
				<xsl:value-of select="$pipeline"/>
			</span>
			<div id="ajax-temp"/>
		</div>
		
	</xsl:template>
	
	<!-- ************** SEARCH INTERFACE FOR CUSTOM WEIGHT QUERIES FROM SPARQL **************** -->
	<xsl:template name="sparql_form">
		<div class="queryGroup">
			<div class="alert alert-danger alert-box" id="sparqlForm-alert" style="display:none">
				<span class="glyphicon glyphicon-warning-sign"/>
				<span class="validationError"/>
			</div>
			<form id="sparqlForm" method="get">
				<div id="sparqlInputContainer">
					<div class="searchItemTemplate">
						<select class="sparql_facets form-control">
							<option>
								<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
							</option>
							<xsl:call-template name="sparql_search_options"/>
						</select>
						<div class="option_container" style="display:inline"/>
						<a class="gateTypeBtn" href="#">
							<span class="glyphicon glyphicon-plus"/>
						</a>
					</div>
				</div>
				<input name="q" id="q_input" type="hidden"/>
				<xsl:if test="string($lang)">
					<input name="lang" type="hidden" value="{$lang}"/>
				</xsl:if>
				<input type="submit" class="btn btn-default" value="{numishare:normalizeLabel('visualize_add_query', $lang)}"/>
			</form>
		</div>
		<div id="sparqlItemTemplate" class="searchItemTemplate">
			<select class="sparql_facets form-control">
				<option>
					<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
				</option>
				<xsl:call-template name="sparql_search_options"/>
			</select>
			<div style="display:inline;" class="option_container"/>
			<a class="gateTypeBtn" href="#">
				<span class="glyphicon glyphicon-plus"/>
			</a>
			<a class="removeBtn" href="#" style="display:none;">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>
		<span id="dateTemplate">
			<xsl:value-of select="numishare:normalize_fields('fromDate', $lang)"/>
			<xsl:text>:</xsl:text>
			<input type="text" class="from_date form-control" name="fromDate"/>
			<select class="from_era form-control">
				<option value="minus">B.C.</option>
				<option value="" selected="selected">A.D.</option>
			</select>
			<xsl:value-of select="numishare:normalize_fields('toDate', $lang)"/>
			<xsl:text>: </xsl:text>
			<input type="text" class="to_date form-control" name="toDate"/>
			<select class="to_era form-control">
				<option value="minus">B.C.</option>
				<option value="" selected="selected">A.D.</option>
			</select>
			<!-- empty, unused input, necessary for generalized validation -->
			<div style="display:none">
				<select name="interval">
					<option value="1">1</option>
				</select>
			</div>
		</span>
	</xsl:template>
	<xsl:template name="sparql_search_options">
		<xsl:variable name="fields" select="concat(string-join(//config/facets/facet[contains(., '_facet')], ','), ',date')"/>
		
		<xsl:for-each select="tokenize($fields, ',')">
			<xsl:variable name="name" select="replace(., '_facet', '')"/>
			<option value="{if ($name = 'date') then 'date' else concat('nmo:has', upper-case(substring($name, 1, 1)), substring($name, 2))}" class="search_option">
				<xsl:value-of select="numishare:normalize_fields($name, $lang)"/>
			</option>
		</xsl:for-each>
	</xsl:template>
	<!-- use the Nomisma getLabel API to resolve the label -->
	<xsl:template name="sparqlLabel">
		<xsl:variable name="hrefs" as="item()*">
			<xsl:analyze-string select="." regex="&lt;([^>]+)&gt;">
				<xsl:matching-substring>
					<xsl:value-of select="document(concat('http://nomisma.org/apis/getLabel?uri=', regex-group(1), '&amp;lang=', $lang))/response"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:variable name="dates" as="item()*">
			<xsl:analyze-string select="." regex="&#x022;(-?\d{{4}})&#x022;">
				<xsl:matching-substring>
					<xsl:value-of select="numishare:normalizeDate(number(translate(., '&#x022;', '')))"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:value-of select="string-join($hrefs, '/')"/>
		<xsl:if test="count($hrefs) &gt; 0 and count($dates) &gt; 0">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<!-- display year range, if applicable -->
		<xsl:value-of select="string-join($dates, '-')"/>
	</xsl:template>
	<!-- ************** GENERATE TABLE FROM PIPELINES THAT EXECUTE SPARQL QUERIES ************** -->
	<xsl:template name="measurementTable">
		<xsl:variable name="iterations" select="ceiling(number($duration) div number($interval))"/>
		<div id="weight-container" style="min-width: 400px; height: 400px; margin: 20px auto"/>
		<!-- class="measurementTable"-->
		<table class="measurementTable">
			<caption>
				<xsl:value-of select="numishare:regularize_node($measurement, $lang)"/>
			</caption>
			<thead>
				<tr>
					<!-- create new table row for basic comparison.  or create a cell for each comparison and row for interval comparison -->
					<xsl:choose>
						<xsl:when test="$duration castable as xs:integer">
							<th id="measurementUnits">
								<xsl:choose>
									<xsl:when test="$measurement='diameter'">mm</xsl:when>
									<xsl:when test="$measurement='weight'">g</xsl:when>
								</xsl:choose>
							</th>
							<!-- generate th -->
							<xsl:for-each select="$tokenized_sparqlQuery">
								<th>
									<xsl:call-template name="sparqlLabel"/>
								</th>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<th/>
							<th id="measurementUnits">
								<xsl:choose>
									<xsl:when test="$measurement='diameter'">mm</xsl:when>
									<xsl:when test="$measurement='weight'">g</xsl:when>
								</xsl:choose>
							</th>
						</xsl:otherwise>
					</xsl:choose>
				</tr>
			</thead>
			<tbody>
				<!-- only show current coin type measurement in display pipeline -->
				<xsl:if test="$pipeline='display'">
					<tr>
						<th>
							<xsl:value-of select="$id"/>
						</th>
						<td>
							<xsl:value-of select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('nmo:hasTypeSeriesItem &lt;', //config/uri_space, $id,'&gt;')),
								'&amp;template=avgMeasurement&amp;measurement=', $measurement))"/>
						</td>
					</tr>
				</xsl:if>
				<!-- create new table row for basic comparison.  or create a cell for each comparison and row for interval comparison -->
				<xsl:choose>
					<xsl:when test="$duration castable as xs:integer">
						<xsl:call-template name="processInterval">
							<xsl:with-param name="start">1</xsl:with-param>
							<xsl:with-param name="iterations" select="$iterations"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$tokenized_sparqlQuery">
							<tr>
								<th>
									<xsl:call-template name="sparqlLabel"/>
								</th>
								<td>
									<xsl:value-of select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('dcterms:source &lt;', $type_series, '&gt; AND ',.)),
										'&amp;template=avgMeasurement&amp;measurement=', $measurement))"/>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</tbody>
		</table>
		<!--<xsl:value-of select="concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('dcterms:source &lt;', $type_series, '&gt; AND ', )),
			'&amp;template=avgMeasurement&amp;measurement=', $measurement)"/>-->
	</xsl:template>
	<xsl:template name="processInterval">
		<xsl:param name="start"/>
		<xsl:param name="iterations"/>
		<xsl:variable name="from">
			<xsl:choose>
				<xsl:when test="((number($start) - 1) * number($interval)) + number($fromDate) = 0">
					<xsl:text>0001</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number(((number($start) - 1) * number($interval)) + number($fromDate), '0000')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="((number($start) * number($interval)) + number($fromDate)) = 0">
					<xsl:text>-0001</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="((number($start) * number($interval)) + number($fromDate)) &lt; number($toDate)">
							<xsl:value-of select="format-number((number($start) * number($interval)) + number($fromDate), '0000')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(number($toDate), '0000')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<th>
				<xsl:value-of select="number($from)"/>/<xsl:value-of select="number($to)"/>
			</th>
			<xsl:for-each select="$tokenized_sparqlQuery">
				<xsl:variable name="hrefs" as="item()*">
					<xsl:analyze-string select="." regex="&lt;([^>]+)&gt;">
						<xsl:matching-substring>
							<xsl:value-of select="document(concat('http://nomisma.org/apis/getLabel?uri=', regex-group(1), '&amp;lang=', $lang))/response"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:variable name="dates" as="item()*">
					<xsl:analyze-string select="." regex="&#x022;(-?\d{{4}})&#x022;">
						<xsl:matching-substring>
							<xsl:value-of select="numishare:normalizeDate(number(translate(., '&#x022;', '')))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<td>
					<xsl:variable name="filter">
						<xsl:text>nmo:hasEndDate ?date FILTER ( ?date &gt;= "</xsl:text>
						<xsl:value-of select="$from"/>
						<xsl:text>"^^xsd:gYear \\and ?date &lt; "</xsl:text>
						<xsl:value-of select="$to"/>
						<xsl:text>"^^xsd:gYear )</xsl:text>
					</xsl:variable>
					<xsl:value-of select="document(concat($request-uri, 'sparql?constraints=', encode-for-uri(concat('dcterms:source &lt;', $type_series, '&gt; AND ', ., ' AND ',       $filter)),
						'&amp;template=avgMeasurement&amp;measurement=', $measurement))"/>
				</td>
			</xsl:for-each>
		</tr>
		<xsl:if test="$start &lt; $iterations">
			<xsl:call-template name="processInterval">
				<xsl:with-param name="start" select="number($start) + 1"/>
				<xsl:with-param name="iterations" select="$iterations"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
