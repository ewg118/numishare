<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

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

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:template match="/config">
		<html>
			<head>
				<title>
					<xsl:value-of select="title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_feedback', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>

				<xsl:for-each select="includes/include">
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

				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<xsl:if test="string(google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="content"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_feedback', $lang)"/>
					</h1>
					<xsl:if test="string(pages/feedback/iframe-url)">
						<iframe src="{pages/feedback/iframe-url}" id="feedback-frame"/>
					</xsl:if>					
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
