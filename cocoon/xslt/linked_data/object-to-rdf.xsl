<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0">
	<xsl:include href="templates.xsl"/>

	<!-- config variables -->
	<xsl:param name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="nomisma"/>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
