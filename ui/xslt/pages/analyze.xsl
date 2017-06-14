<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../templates-analyze.xsl"/>
	<xsl:include href="../templates-search.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:variable name="pipeline">analyze</xsl:variable>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	
	<!-- request parameters -->
	<xsl:param name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'analyze'))"/>
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

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="calculate" select="doc('input:request')/request/parameters/parameter[name='calculate']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name='compare']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<xsl:param name="chartType" select="doc('input:request')/request/parameters/parameter[name='chartType']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name='exclude']/value"/>
	<xsl:param name="options" select="doc('input:request')/request/parameters/parameter[name='options']/value"/>
	
	<!-- empty variables -->
	<xsl:variable name="nudsGroup" as="node()*">
		<empty/>
	</xsl:variable>
	<xsl:variable name="id"/>

	<!-- config variables -->
	<xsl:variable name="url" select="//config/url"/>
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" as="element()*">
		<xsl:copy-of select="//lst[@name='facet_fields']"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text><xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
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
				<!-- analysis scripts -->
				<script type="text/javascript" src="{$include_path}/javascript/highcharts.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/modules/exporting.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/analyze.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/analysis_functions.js"/>
				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>

				<!-- google analytics -->
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid">
			<xsl:if test="$lang='ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>							
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
					</h1>
					<span style="display:none" id="vis-pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>

					<ul class="nav nav-pills" id="tabs">
						<li class="active">
							<a href="#visualization" data-toggle="pill">
								<xsl:value-of select="numishare:normalizeLabel('display_visualization', $lang)"/>
							</a>
						</li>
						<li>
							<a href="#date-analysis" data-toggle="pill">
								<xsl:value-of select="numishare:normalizeLabel('display_date-analysis', $lang)"/>
							</a>
						</li>
						<li>
							<a href="#data-download" data-toggle="pill">
								<xsl:value-of select="numishare:normalizeLabel('display_data-download', $lang)"/>
							</a>
						</li>
					</ul>
					<div class="tab-content">
						<div class="tab-pane active" id="visualization">
							<xsl:call-template name="hoard-visualization">
								<xsl:with-param name="action">#visualization</xsl:with-param>
							</xsl:call-template>
						</div>
						<div class="tab-pane" id="date-analysis">
							<xsl:call-template name="date-vis">
								<xsl:with-param name="action">#date-analysis</xsl:with-param>
							</xsl:call-template>
						</div>
						<div class="tab-pane" id="data-download">
							<xsl:call-template name="data-download"/>
						</div>
					</div>
					<div style="display:none">
						<div id="filterHoards">
							<h3>
								<xsl:value-of select="numishare:normalizeLabel('visualize_filter_hoards', $lang)"/>
							</h3>
							<xsl:call-template name="search_forms"/>
						</div>
					</div>
					<span id="formId" style="display:none"/>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
