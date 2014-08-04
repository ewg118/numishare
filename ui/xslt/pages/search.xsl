<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="../header.xsl"/>
	<xsl:include href="../footer.xsl"/>
	<xsl:include href="../templates_search.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="pipeline">search</xsl:param>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="display_path"/>
	<xsl:param name="include_path">../</xsl:param>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']" as="node()*"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}ui/images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$include_path}ui/css/style.css" rel="stylesheet"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/search.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/search_functions.js"/>
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="search"/>
				<xsl:call-template name="footer"/>
				<div class="hidden">
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="search">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</h1>
					<p>This page allows you to search the entire collection for specific terms or keywords.</p>
					<xsl:call-template name="search_forms"/>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
