<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:template match="/nuds:nuds">
		<xsl:variable name="model" as="element()*">
			<_object>
				<html>
					<xsl:text>&lt;p&gt;</xsl:text>
					<xsl:value-of select="descendant::nuds:title[@xml:lang='en']"/>
					<xsl:text>&lt;/p&gt;</xsl:text>
				</html>
				<id>
					<xsl:value-of select="nuds:control/nuds:recordId"/>
				</id>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>
</xsl:stylesheet>
