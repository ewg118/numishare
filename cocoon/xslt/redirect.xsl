<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:param name="id"/>
	<xsl:variable name="to" select="//redirect[@from=$id]/@to"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Change of resource URI</title>
				<meta http-equiv="refresh" content="0; url=id/{$to}"/>
			</head>
			<body>
				<p>The URI system has changed. If this page doesn't automatically redirect, click <a href="id/{$to}">here</a>.</p>
			</body>
		</html>
	</xsl:template>


</xsl:stylesheet>
