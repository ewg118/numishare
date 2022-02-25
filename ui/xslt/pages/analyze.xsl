<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:nm="http://nomisma.org/id/" xmlns:math="http://exslt.org/math" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../templates-analyze.xsl"/>
	<xsl:include href="../templates-search.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:variable name="pipeline">analyze</xsl:variable>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- request parameters -->
	<xsl:param name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'analyze'))"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name = 'exclude']/value"/>
	<xsl:param name="options" select="doc('input:request')/request/parameters/parameter[name = 'options']/value"/>

	<!-- empty variables -->
	<xsl:variable name="nudsGroup" as="node()*">
		<empty/>
	</xsl:variable>
	<xsl:variable name="id"/>

	<!-- config variables -->
	<xsl:variable name="url" select="//config/url"/>
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- get the facets as a sequence -->
	<xsl:variable name="facets" select="//config/facets/facet"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>

				<xsl:for-each select="//config/includes/include">
					<xsl:choose>
						<xsl:when test="@type = 'css'">
							<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
						</xsl:when>
						<xsl:when test="@type = 'javascript'">
							<script type="text/{@type}" src="{@url}"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				
				<!-- analysis scripts -->
				<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/d3plus-plot.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/hoard_analysis_functions.js"/>				
				<script type="text/javascript" src="{$include_path}/javascript/search_functions.js"/>
				
				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

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
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
					</h1>

					<xsl:call-template name="hoard-visualization">
						<xsl:with-param name="hidden" select="if (string($dist) and count($compare) &gt; 0) then false() else true()"/>
						<xsl:with-param name="page">page</xsl:with-param>
						<xsl:with-param name="compare" select="$compare"/>
					</xsl:call-template>
					
					<div class="hidden">
						<span id="display_path">
							<xsl:value-of select="$display_path"/>
						</span>
						<span id="page">page</span>
						<div id="filterHoards">
							<xsl:call-template name="search_forms"/>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
