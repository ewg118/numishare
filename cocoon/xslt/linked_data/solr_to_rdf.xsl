<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">
	<xsl:include href="templates.xsl"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:param name="mode"/>

	<xsl:param name="url" select="/content/config/url"/>
	<xsl:param name="uri_space" select="/content/config/uri_space"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
						<foaf:name>
							<xsl:value-of select="/content/config/template/agencyName"/>
						</foaf:name>
					</foaf:Organization>
					<xsl:apply-templates select="//doc" mode="pelagios"/>
				</xsl:when>
				<xsl:when test="$mode='nomisma'">
					<xsl:apply-templates select="//doc" mode="nomisma"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
