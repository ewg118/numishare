<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="display_path"/>
	<xsl:param name="lang"/>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="calculate"/>
	<xsl:param name="compare"/>
	<xsl:param name="type"/>
	<xsl:param name="chartType"/>
	<xsl:param name="exclude"/>

	<!-- config variables -->
	<xsl:variable name="url">
		<xsl:value-of select="//config/url"/>
	</xsl:variable>
	<xsl:variable name="collection_type" select="//config/collection_type"/>
	<xsl:variable name="id"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Analyze Hoards</xsl:text>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- Core + Skin CSS -->
				<link type="text/css" href="{$display_path}themes/{//config/theme/jquery_ui_theme}.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}jquery.fancybox-1.3.4.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"/>

				<!-- menu -->
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.core.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.widget.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.position.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.button.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menu.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menubar.js"/>
				<script type="text/javascript" src="{$display_path}javascript/numishare-menu.js"/>

				<!-- analysis scripts -->
				<script type="text/javascript" src="{$display_path}javascript/highcharts.js"/>
				<script type="text/javascript" src="{$display_path}javascript/modules/exporting.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/analysis_functions.js"/>
				<!-- filter functions -->
				<script type="text/javascript" src="{$display_path}javascript/jquery.fancybox-1.3.4.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/search_functions.js"/>

				<!-- google analytics -->
				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics/script"/>
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
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
					<h1>Quantitative Analysis</h1>
					<div id="tabs">
						<ul>
							<li>
								<a href="#visualization">Visualization</a>
							</li>
							<li>
								<a href="#date-analysis">Date Analysis</a>
							</li>
							<li>
								<a href="#data-download">Data Download</a>
							</li>
						</ul>
						<div id="visualization" class="tab">
							<h3>Typological Visualization</h3>
							<xsl:call-template name="visualization">
								<xsl:with-param name="action">#visualization</xsl:with-param>
							</xsl:call-template>
						</div>
						<div id="date-analysis" class="tab">
							<h3>Date Analysis</h3>
							<xsl:call-template name="date-vis">
								<xsl:with-param name="action">#date-analysis</xsl:with-param>
							</xsl:call-template>
						</div>
						<div id="data-download" class="tab">
							<h3>Data Download</h3>
							<xsl:call-template name="data-download"/>
						</div>
					</div>
					<div style="display:none">
						<div id="filterHoards">
							<h3>Filter Hoards</h3>
							<xsl:call-template name="search_forms"/>
						</div>
					</div>
					<span id="formId" style="display:none"/>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
