<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<!-- includes -->
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../templates-search.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:param name="pipeline">maps</xsl:param>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path" select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>

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
	<xsl:variable name="request-uri" select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'maps'))"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name = 'facet_fields']" as="node()*"/>

	<!-- blank params (from html templates) -->
	<xsl:param name="mode"/>
	<xsl:param name="sort"/>
	<xsl:param name="start" as="xs:integer"/>
	<xsl:param name="rows" as="xs:integer"/>
	<xsl:param name="side"/>
	<xsl:param name="layout"/>
	<xsl:param name="authenticated"/>
	<xsl:variable name="numFound" select="//result[@name = 'response']/@numFound" as="xs:integer"/>
	<xsl:variable name="image"/>

	<!-- config variables -->
	<xsl:variable name="collection_type" select="/content//collection_type"/>
	<xsl:variable name="positions" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/positions"/>
		</config>
	</xsl:variable>

	<xsl:template match="/">
		<html style="height:100%">
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>

				<!-- jquery -->
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
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}/css/bootstrap-multiselect.css" type="text/css"/>
				<!-- local theme and styling -->
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>

				<!-- maps CSS-->
				<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
				<link type="text/css" href="{$include_path}/css/leaflet.legend.css" rel="stylesheet"/>

				<!-- js -->
				<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/leaflet.legend.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/map_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/facet_functions.js"/>

				<!-- Google Analytics -->
				<xsl:call-template name="google_analytics">
					<xsl:with-param name="id" select="//config/google_analytics_tag"/>
				</xsl:call-template>
			</head>
			<body style="height:100%">
				<xsl:call-template name="maps"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="maps">
		<div class="container-fluid" style="height:100%">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$numFound &gt; 0">

					<div class="row" style="height:100%">						
						<div class="col-md-12 fullscreen" style="height:100%">
							<div id="mapcontainer"/>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<a name="results"/>
							<div id="results"/>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="row">
						<div class="col-md-12">
							<h1> No results found.</h1>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>

			<div id="backgroundPopup"/>
			<div id="map_filters" style="display:none">
				<xsl:call-template name="advanced-search-form">
					<xsl:with-param name="mode" select="$pipeline"/>
				</xsl:call-template>
			</div>

			<div class="hidden">
				<input id="facet_form_query" name="q" value="*:*" type="hidden"/>
				<xsl:if test="string($langParam)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<span id="collection_type">
					<xsl:value-of select="$collection_type"/>
				</span>
				<span id="path">
					<xsl:value-of select="$display_path"/>
				</span>
				<span id="include_path">
					<xsl:value-of select="$include_path"/>
				</span>
				<span id="pipeline">
					<xsl:value-of select="$pipeline"/>
				</span>
				<span id="mapboxKey">
					<xsl:value-of select="//config/mapboxKey"/>
				</span>
				<a href="maps?q={if (string($q)) then encode-for-uri($q) else '*:*'}" id="permalink"></a>
				<span id="section">maps</span>
				<span id="baselayers">
					<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
				</span>
				<span id="legend">
					[{"label": "<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>", "type": "rectangle", "fillColor": "#6992fd", "color": "black", "weight": 1},
					{"label": "<xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>", "type": "rectangle", "fillColor": "#d86458", "color": "black", "weight": 1}
					<xsl:if test="not($collection_type = 'hoard')">
						,{"label": "<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>", "type": "rectangle", "fillColor": "#f98f0c", "color": "black", "weight": 1},
						{"label": "<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>", "type": "rectangle", "fillColor": "#00e64d", "color": "black", "weight": 1}
					</xsl:if>]					
				</span>
				<div id="ajax-temp"/>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
