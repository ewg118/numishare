<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:void="http://rdfs.org/ns/void#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#" exclude-result-prefixes="xs" version="2.0">
	<xsl:param name="mode"/>

	<xsl:template match="/config">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<xsl:call-template name="pelagios"/>
				</xsl:when>
				<xsl:when test="$mode='nomisma'">
					<xsl:call-template name="nomisma"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template name="pelagios">
		<void:dataSet>
			<dcterms:title>
				<xsl:value-of select="title"/>
			</dcterms:title>
			<dcterms:description>
				<xsl:value-of select="description"/>
			</dcterms:description>
			<dcterms:license rdf:resource="{template/license}"/>
			<dcterms:subject rdf:resource="http://dbpedia.org/resource/Annotation"/>
			<void:dataDump rdf:resource="{url}pelagios.rdf"/>
		</void:dataSet>
	</xsl:template>
	
	<xsl:template name="nomisma">
		<void:dataSet>
			<dcterms:title>
				<xsl:value-of select="title"/>
			</dcterms:title>
			<dcterms:description>
				<xsl:value-of select="description"/>
			</dcterms:description>
			<dcterms:license rdf:resource="{template/license}"/>
			<dcterms:subject rdf:resource="http://dbpedia.org/resource/Annotation"/>
			<void:dataDump rdf:resource="{url}nomisma.rdf"/>
		</void:dataSet>
	</xsl:template>
</xsl:stylesheet>
