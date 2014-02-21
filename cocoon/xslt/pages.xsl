<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xhtml" encoding="UTF-8"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="stub"/>
	<xsl:param name="pipeline"/>
	<xsl:param name="lang"/>

	<xsl:param name="display_path">
		<xsl:text>../</xsl:text>
	</xsl:param>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="//page[@stub = $stub]/title"/>
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
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//page[@stub = $stub]/text), '&lt;/div&gt;'))"/>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
