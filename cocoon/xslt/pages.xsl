<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xhtml" encoding="UTF-8"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="stub"/>
	<xsl:param name="pipeline"/>
	<xsl:param name="lang"/>

	<xsl:param name="display_path">
		<xsl:if test="$pipeline!='contributors'">../</xsl:if>
	</xsl:param>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="$pipeline='contributors'">
							<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//page[@stub = $stub]/title"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="pages"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="pages">
		<div class="container-fluid" id="content">
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="$pipeline='contributors'">
							<h1>
								<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
							</h1>
							<cinclude:include src="cocoon:/widget?template=contributors{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="//page[@stub = $stub]/text"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
