<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
	 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0">
	<xsl:include href="templates.xsl"/>

	<!-- config variables -->
	<xsl:param name="url" select="/content/config/url"/>
	<xsl:param name="uri_space" select="/content/config/uri_space"/>

	<xsl:template match="/">
		<rdf:RDF>			
			<xsl:for-each select="descendant::*:semanticDeclaration">
				<xsl:namespace name="{*:prefix}" select="*:namespace"/>				
			</xsl:for-each>
			<xsl:choose>
				<xsl:when
					test="descendant::*:maintenanceStatus != 'new' and descendant::*:maintenanceStatus != 'derived' and descendant::*:maintenanceStatus != 'revised'">
					<xsl:variable name="element">
						<xsl:choose>
							<xsl:when test="/content/*[not(self::config)]/local-name()='nudsHoard'">nmo:Hoard</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="/content/*[not(self::config)]/@recordType='conceptual'">nmo:TypeSeriesItem</xsl:when>
									<xsl:when test="/content/*[not(self::config)]/@recordType='physical'">nmo:NumismaticObject</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="{$element}">
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="concat($url, 'id/', descendant::*:recordId)"/>
						</xsl:attribute>
						<xsl:for-each select="descendant::*:otherRecordId[string(@semantic)]">
							<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
							<xsl:variable name="prefix" select="substring-before(@semantic, ':')"/>
							<xsl:variable name="namespace" select="ancestor::*:control/*:semanticDeclaration[*:prefix=$prefix]/*:namespace"/>
							<xsl:element name="{@semantic}" namespace="{$namespace}">
								<xsl:attribute name="rdf:resource" select="$uri"/>
							</xsl:element>							
						</xsl:for-each>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="nomisma"/>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
