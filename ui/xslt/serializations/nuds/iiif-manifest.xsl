<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="recordType" select="//nuds:nuds/@recordType"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="objectUri" select="
		if (/content/config/uri_space) then
		concat(/content/config/uri_space, $id)
		else
		concat($url, 'id/', $id)"/>


	<xsl:template match="/">
		<xsl:apply-templates select="//nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:variable name="model" as="element()*">
			<model>
				<label>
					<xsl:value-of select="//nuds:descMeta/nuds:title[@xml:lang='en']"/>
				</label>
			</model>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>
	
	<!-- XSLT templates for rendering the $model into JSON -->
	<xsl:template match="model">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}</xsl:text>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
	</xsl:template>

</xsl:stylesheet>
