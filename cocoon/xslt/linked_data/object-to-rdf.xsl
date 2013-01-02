<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl gml nm nuds nh" xmlns:exsl="http://exslt.org/common"
	xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:oac="http://www.openannotation.org/ns/" xmlns:owl="http://www.w3.org/2002/07/owl#" version="2.0">
	<xsl:include href="templates.xsl"/>
	
	<!-- config variables -->
	<xsl:param name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="cidoc"/>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
