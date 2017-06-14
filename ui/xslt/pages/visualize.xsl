<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../templates-search.xsl"/>
	<xsl:include href="../templates-visualize.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:variable name="pipeline">visualize</xsl:variable>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	
	<!-- request parameters -->
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'visualize'))"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<!-- quantitative analysis parameters -->
	<!-- typological comparison -->
	<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name='compare']/value"/>
	<xsl:param name="custom" select="doc('input:request')/request/parameters/parameter[name='custom']/value"/>
	<xsl:param name="options" select="doc('input:request')/request/parameters/parameter[name='options']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<!-- measurement comparison -->
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name='measurement']/value"/>
	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name='numericType']/value"/>
	<xsl:param name="interval" select="doc('input:request')/request/parameters/parameter[name='interval']/value"/>
	<xsl:param name="fromDate" select="doc('input:request')/request/parameters/parameter[name='fromDate']/value"/>
	<xsl:param name="toDate" select="doc('input:request')/request/parameters/parameter[name='toDate']/value"/>
	<xsl:param name="sparqlQuery" select="doc('input:request')/request/parameters/parameter[name='sparqlQuery']/value"/>
	<xsl:variable name="tokenized_sparqlQuery" as="item()*">
		<xsl:sequence select="tokenize($sparqlQuery, '\|')"/>
	</xsl:variable>
	<xsl:variable name="duration" select="number($toDate) - number($fromDate)"/>
	<!-- both -->
	<xsl:param name="chartType" select="doc('input:request')/request/parameters/parameter[name='chartType']/value"/>
	<!-- blank variables that are used in object pages -->
	<xsl:variable name="rdf" as="node()*">
		<empty/>
	</xsl:variable>
	<xsl:variable name="calculate"/>
	<xsl:variable name="id"/>
	<!-- variables -->
	<xsl:variable name="category_normalized">
		<xsl:value-of select="numishare:normalize_fields($category, $lang)"/>
	</xsl:variable>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="qString" select="if (string($q)) then $q else '*:*'"/>
	<!-- config variables -->
	<xsl:variable name="url" select="//config/url"/>
	<xsl:variable name="collection_type" select="//config/collection_type"/>
	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']" as="node()*"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<!-- required libraries -->
				<script type="text/javascript" src="{$include_path}/javascript/highcharts.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/modules/exporting.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/visualize_functions.js"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="visualize"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="visualize">
		<div class="container-fluid">
			<xsl:if test="$lang='ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>							
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
					</h1>
					<p><xsl:value-of select="numishare:normalizeLabel('visualize_desc', $lang)"/>: <a href="http://wiki.numismatics.org/numishare:visualize" target="_blank"
							>http://wiki.numismatics.org/numishare:visualize</a>.</p>
					<!-- display tabs for measurement analysis only if there is a sparql endpoint-->
					<xsl:choose>
						<xsl:when test="string(//config/sparql_endpoint)">
							<ul class="nav nav-pills">
								<li>
									<xsl:if test="not(string($measurement))">
										<xsl:attribute name="class">active</xsl:attribute>
									</xsl:if>
									<a href="#typological" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('visualize_typological', $lang)"/>
									</a>
								</li>
								<li>
									<xsl:if test="string($measurement)">
										<xsl:attribute name="class">active</xsl:attribute>
									</xsl:if>
									<a href="#measurements" data-toggle="pill">
										<xsl:value-of select="numishare:normalizeLabel('visualize_measurement', $lang)"/>
									</a>
								</li>
							</ul>
							<div class="tab-content">
								<div class="tab-pane {if (not(string($measurement))) then 'active' else ''}" id="typological">
									<xsl:apply-templates select="/content/response"/>
								</div>
								<div class="tab-pane {if (string($measurement)) then 'active' else ''}" id="measurements">
									<xsl:call-template name="measurementForm"/>
								</div>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/content/response"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="response">
		<xsl:call-template name="solr-visualization"/>
		<div style="display:none">
			<div id="searchBox">
				<h3>
					<xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/>
				</h3>
				<xsl:call-template name="search_forms"/>
			</div>
		</div>
	</xsl:template>
	<!-- ************** SOLR-BASED VISUALIZATION ************** -->
	<xsl:template name="solr-visualization">
		<!-- display visualization over form -->
		<xsl:variable name="chartTypes">column,bar</xsl:variable>
		<form action="#typological" id="visualize-form" style="margin:40px;" method="get">
			<div class="row">
				<h3>1. <xsl:value-of select="numishare:normalizeLabel('visualize_response_type', $lang)"/></h3>
				<div class="col-md-2">
					<input type="radio" name="type" value="percentage">
						<xsl:if test="$type = 'percentage' or not(string($type))">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="type-radio">
						<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
					</label>
				</div>
				<div class="col-md-2">
					<input type="radio" name="type" value="count">
						<xsl:if test="$type = 'count'">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="type-radio">
						<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
					</label>
				</div>
			</div>
			<div class="row">
				<h3>2. <xsl:value-of select="numishare:normalizeLabel('visualize_chart_type', $lang)"/></h3>
				<xsl:for-each select="tokenize($chartTypes, ',')">
					<div class="col-md-2">
						<input type="radio" name="chartType" value="{.}">
							<xsl:choose>
								<xsl:when test="$chartType = .">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
								<xsl:when test=". = 'column' and not(string($chartType))">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:when>
							</xsl:choose>
						</input>
						<label for="chartType-radio">
							<xsl:value-of select="numishare:normalizeLabel(concat('chart_', .), $lang)"/>
						</label>
					</div>
				</xsl:for-each>
			</div>
			<!-- include checkbox categories -->
			<div class="row">
				<h3>3. <xsl:value-of select="numishare:normalizeLabel('visualize_categories', $lang)"/></h3>
				<xsl:for-each select="//lst[@name='facet_fields']/lst">
					<xsl:variable name="query_fragment" select="@name"/>
					<div class="col-md-2">
						<xsl:choose>
							<xsl:when test="contains($category, $query_fragment)">
								<input type="checkbox" id="{$query_fragment}-checkbox" checked="checked" value="{$query_fragment}" class="calculate-checkbox"/>
							</xsl:when>
							<xsl:otherwise>
								<input type="checkbox" id="{$query_fragment}-checkbox" value="{$query_fragment}" class="calculate-checkbox"/>
							</xsl:otherwise>
						</xsl:choose>
						<label for="{$query_fragment}-checkbox">
							<xsl:value-of select="numishare:normalize_fields(@name, $lang)"/>
						</label>
					</div>
				</xsl:for-each>
				<div id="customQueryDiv">
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_add_custom', $lang)"/>
						<small style="margin-left:10px;">
							<a href="#searchBox" class="addQuery" id="customQuery">
								<span class="glyphicon glyphicon-plus"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/>
							</a>
						</small>
					</h4>
					<xsl:for-each select="tokenize($custom, '\|')">
						<div class="customQuery">
							<b><xsl:value-of select="numishare:normalizeLabel('visualize_custom_query', $lang)"/>: </b>
							<span>
								<xsl:value-of select="."/>
							</span>
							<a href="#" class="removeQuery">
								<span class="glyphicon glyphicon-remove"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<h3>
					<xsl:choose>
						<xsl:when test="string($q)">4. <xsl:value-of select="numishare:normalizeLabel('visualize_compare_optional', $lang)"/>
						</xsl:when>
						<xsl:otherwise>4. <xsl:value-of select="numishare:normalizeLabel('visualize_compare', $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
					<small style="margin-left:10px;">
						<a href="#searchBox" class="addQuery" id="compareQuery">
							<span class="glyphicon glyphicon-plus"/>
							<xsl:value-of select="numishare:normalizeLabel('visualize_add_query', $lang)"/>
						</a>
					</small>
				</h3>
				<div id="compareQueryDiv">
					<xsl:for-each select="tokenize($compare, '\|')">
						<div class="compareQuery">
							<b><xsl:value-of select="numishare:normalizeLabel('visualize_comparison_query', $lang)"/>: </b>
							<span>
								<xsl:value-of select="."/>
							</span>
							<a href="#" class="removeQuery">
								<span class="glyphicon glyphicon-remove"/>
								<xsl:value-of select="numishare:normalizeLabel('visualize_remove_query', $lang)"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
				<div>
					<h4>
						<xsl:value-of select="numishare:normalizeLabel('visualize_optional_settings', $lang)"/>
						<span style="font-size:60%;margin-left:10px;">
							<a href="#" class="optional-button" id="visualize-options">
								<xsl:value-of select="numishare:normalizeLabel('visualize_hide-show', $lang)"/>
							</a>
						</span>
					</h4>
					<div class="optional-div" style="display:none;">
						<div class="form-group">
							<label for="stacking">
								<xsl:value-of select="numishare:normalizeLabel('visualize_stacking_options', $lang)"/>
							</label>
							<select id="stacking" class="form-control">
								<option value="">
									<xsl:value-of select="numishare:normalizeLabel('results_select', $lang)"/>
								</option>
								<option value="stacking:normal">
									<xsl:if test="contains($options, 'stacking:normal')">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="numishare:normalizeLabel('numeric_cumulative', $lang)"/>
								</option>
								<option value="stacking:percent">
									<xsl:if test="contains($options, 'stacking:percent')">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
								</option>
							</select>
						</div>
					</div>
				</div>
			</div>
			<input type="hidden" name="category" id="calculate-input" value=""/>
			<input type="hidden" name="compare" id="compare-input" value=""/>
			<input type="hidden" name="options" id="options-input" value="{$options}"/>
			<input type="hidden" name="custom" id="custom-input" value=""/>
			<xsl:if test="string($q)">
				<input type="hidden" name="q" value="{$q}"/>
			</xsl:if>
			<xsl:if test="string($langParam)">
				<input type="hidden" name="lang" value="{$lang}"/>
			</xsl:if>
			<br/>
			<input type="submit" value="{numishare:normalizeLabel('visualize_generate', $lang)}" id="submit-calculate" class="btn btn-default"/>
		</form>
		<!-- output charts and tables for facets -->
		<xsl:if test="string($category) and (string($q) or string($compare))">
			<xsl:for-each select="tokenize($category, '\|')">
				<xsl:call-template name="quant">
					<xsl:with-param name="facet" select="."/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="string($custom)">
			<xsl:for-each select="tokenize($custom, '\|')">
				<xsl:call-template name="quant">
					<xsl:with-param name="customQuery" select="."/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="quant">
		<xsl:param name="facet"/>
		<xsl:param name="customQuery"/>
		<xsl:variable name="counts" as="element()*">
			<counts>
				<xsl:choose>
					<xsl:when test="string($facet)">
						<!-- if there is a $q parameter, gather data -->
						<xsl:if test="string($q)">
							<xsl:copy-of select="document(concat($request-uri, 'get_vis_quant?q=', encode-for-uri($q), '&amp;category=', $facet, '&amp;type=', $type, '&amp;lang=', $lang ))"/>
						</xsl:if>
						<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<xsl:copy-of select="document(concat($request-uri, 'get_vis_quant?q=', encode-for-uri(.), '&amp;category=', $facet, '&amp;type=', $type, '&amp;lang=', $lang ))"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:when>
					<xsl:when test="string($customQuery)">
						<!-- if there is a $q parameter, gather data -->
						<xsl:if test="string($q)">
							<xsl:copy-of select="document(concat($request-uri, 'get_vis_custom?q=', encode-for-uri($q), '&amp;customQuery=', encode-for-uri($customQuery), '&amp;total=', $numFound, '&amp;type=', $type, '&amp;lang=', $lang
								))"/>
						</xsl:if>
						<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<xsl:copy-of select="document(concat($request-uri, 'get_vis_custom?q=', encode-for-uri(.), '&amp;customQuery=', encode-for-uri($customQuery), '&amp;total=', $numFound, '&amp;type=',
									$type, '&amp;lang=', $lang ))"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</counts>
		</xsl:variable>
		<!-- only display chart if there are counts -->
		<xsl:if test="count($counts//name) &gt; 0">
			<div id="{.}-container" style="min-width: 400px; height: 400px; margin: 0 auto"/>
			<table class="calculate" id="{.}-table">
				<caption>
					<xsl:choose>
						<xsl:when test="$type='count'">
							<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="numishare:normalizeLabel('numeric_percentage', $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="string($facet)">
							<xsl:value-of select="numishare:normalize_fields($facet, $lang)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$customQuery"/>
						</xsl:otherwise>
					</xsl:choose>
				</caption>
				<thead>
					<tr>
						<th/>
						<xsl:if test="string($q)">
							<th>
								<xsl:value-of select="$q"/>
							</th>
						</xsl:if>
						<xsl:if test="string($compare)">
							<xsl:for-each select="tokenize($compare, '\|')">
								<th>
									<xsl:value-of select="."/>
								</th>
							</xsl:for-each>
						</xsl:if>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="distinct-values($counts//name)">
						<xsl:sort/>
						<xsl:variable name="name" select="."/>
						<tr>
							<th>
								<xsl:value-of select="$name"/>
							</th>
							<xsl:if test="string($q)">
								<td>
									<xsl:choose>
										<xsl:when test="number($counts//query[@q=$q]/*[local-name()='name'][text()=$name]/@count)">
											<xsl:value-of select="$counts//query[@q=$q]/*[local-name()='name'][text()=$name]/@count"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>0</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:if>
							<xsl:if test="string($compare)">
								<xsl:for-each select="tokenize($compare, '\|')">
									<xsl:variable name="new-q" select="."/>
									<td>
										<xsl:choose>
											<xsl:when test="number($counts//query[@q=$new-q]/*[local-name()='name'][text()=$name]/@count)">
												<xsl:value-of select="$counts//query[@q=$new-q]/*[local-name()='name'][text()=$name]/@count"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:for-each>
							</xsl:if>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
