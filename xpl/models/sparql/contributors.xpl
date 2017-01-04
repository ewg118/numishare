<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">				
				<xsl:variable name="endpoint" select="/config/sparql_endpoint"/>
				
				<xsl:variable name="query">
					<![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX owl:	<http://www.w3.org/2002/07/owl#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX org:	<http://www.w3.org/ns/org#>
PREFIX void:	<http://rdfs.org/ns/void#>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>

SELECT ?dataset ?publisher ?collection ?collectionLabel ?thumbnail ?homepage ?memberOf ?title ?description ?license ?rights (COUNT(?dataset) AS ?count) {
    ?type dcterms:source <TYPE_SERIES> .
    ?object nmo:hasTypeSeriesItem ?type ;
            void:inDataset ?dataset .
  OPTIONAL {?object nmo:hasCollection ?collection .
           ?collection skos:prefLabel ?collectionLabel . FILTER langMatches(lang(?collectionLabel), "en")
           OPTIONAL {?collection foaf:thumbnail ?thumbnail}
           OPTIONAL {?collection foaf:homepage ?homepage}
           OPTIONAL {?collection org:memberOf ?memberOf}}
  ?dataset dcterms:publisher ?publisher ;
           dcterms:title ?title FILTER (lang(?title) = "" || langMatches(lang(?title), "en")).
  OPTIONAL {?dataset dcterms:license ?license }
  OPTIONAL {?dataset dcterms:rights ?rights }
  ?dataset dcterms:description ?description FILTER (lang(?description) = "" || langMatches(lang(?description), "en")) .
  OPTIONAL {?dataset foaf:thumbnail ?thumbnail}} GROUP BY ?dataset ?publisher ?collection ?collectionLabel ?title ?thumbnail ?homepage ?memberOf ?description ?license ORDER BY ?publisher]]>
				</xsl:variable>
				
				<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'TYPE_SERIES', /config/type_series))), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
