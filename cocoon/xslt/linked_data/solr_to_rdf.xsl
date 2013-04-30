<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl nuds nh xlink mets" xmlns:exsl="http://exslt.org/common"
	xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:georss="http://www.georss.org/georss" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oac="http://www.openannotation.org/ns/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:dc="http://purl.org/dc/terms/" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:mets="http://www.loc.gov/METS/"  version="2.0">
	<xsl:include href="templates.xsl"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:param name="mode"/>
	
	<xsl:param name="url">
		<xsl:value-of select="/content/config/url"/>
	</xsl:param>
	
	<xsl:template match="/">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<xsl:apply-templates select="//doc" mode="pelagios"/>
				</xsl:when>
				<xsl:when test="$mode='ctype'">
					<xsl:apply-templates select="//doc" mode="ctype"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
