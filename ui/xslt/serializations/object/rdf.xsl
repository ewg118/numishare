<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs nuds nh xlink"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:georss="http://www.georss.org/georss" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#"
	xmlns:void="http://rdfs.org/ns/void#" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nmo="http://nomisma.org/ontology#" version="2.0">
	<xsl:include href="rdf-templates.xsl"/>
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="mode"/>
	<xsl:variable name="nudsGroup" as="element()*">
		<blank/>
	</xsl:variable>
	<xsl:variable name="rdf" as="element()*">
		<blank/>
	</xsl:variable>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="nomisma"/>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
