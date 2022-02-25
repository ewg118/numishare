<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../vis-templates.xsl"/>

	<!-- request params: see vis-templates for parameter declarations -->

	<!-- empty variables to account for vis templates -->
	<xsl:variable name="base-query"/>
	<xsl:variable name="objectUri"/>
	<xsl:variable name="type"/>
	<xsl:variable name="classes" as="item()*">
		<classes/>
	</xsl:variable>

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

	<!-- config or other variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:variable name="mode">page</xsl:variable>

	<xsl:template match="/">
		<xsl:param name="interface" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>

		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="$interface = 'distribution'">Typological Distribution</xsl:when>
						<xsl:when test="$interface = 'metrical'">Metrical Analysis</xsl:when>
					</xsl:choose>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
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
				<link rel="stylesheet" type="text/css" href="{$include_path}/css/style.css"/>

				<!-- visualization libraries -->
				<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/d3plus-plot.full.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/vis_functions.js"/>

				<!-- google analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body">
					<xsl:with-param name="interface" select="$interface"/>
				</xsl:call-template>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<xsl:param name="interface"/>

		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
					</h1>
					<p><xsl:value-of select="numishare:normalizeLabel('visualize_desc', $lang)"/>: <a href="http://wiki.numismatics.org/numishare:visualize"
						target="_blank">http://wiki.numismatics.org/numishare:visualize</a>.</p>
					<xsl:choose>
						<xsl:when test="$interface = 'distribution'">
							<xsl:call-template name="distribution-form">
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$interface = 'metrical'">
							<xsl:call-template name="metrical-form">
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>

				</div>
			</div>

		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div class="hidden">
			<span id="path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="page">
				<xsl:value-of select="$mode"/>
			</span>
			<span id="interface">
				<xsl:value-of select="$interface"/>
			</span>
			<xsl:call-template name="field-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="compare-container-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="date-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="ajax-loader-template"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
