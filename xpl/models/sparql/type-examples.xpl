<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
				<xsl:variable name="uri" select="concat(/config/uri_space, $id)"/>
				

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
				
				<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX void:	<http://rdfs.org/ns/void#>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>

SELECT ?object ?title ?identifier ?findUri ?findspot ?hoard ?collection ?publisher ?dataset ?datasetTitle ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef  WHERE {
?object nmo:hasTypeSeriesItem <typeURI> ;
  rdf:type nmo:NumismaticObject ;
  dcterms:title ?title .
OPTIONAL { ?object dcterms:identifier ?identifier}
OPTIONAL { ?object nmo:hasCollection ?colUri .
?colUri skos:prefLabel ?collection FILTER(langMatches(lang(?collection), "EN"))}
?object void:inDataset ?dataset .
?dataset dcterms:publisher ?publisher ;
	dcterms:title ?datasetTitle FILTER (lang(?datasetTitle) = "" || langMatches(lang(?datasetTitle), "en")) .
OPTIONAL {?object nmo:hasFindspot ?findUri .
?findUri foaf:name ?findspot }
OPTIONAL {?object nmo:hasFindspot ?findUri .
?findUri rdfs:label ?findspot }
OPTIONAL {?object nmo:hasFindspot ?findUri .
?nomismaUri geo:location ?findUri ;
	skos:prefLabel ?findspot FILTER langMatches(lang(?findspot), "en")}
OPTIONAL {?object dcterms:isPartOf ?hoard .
 ?hoard a nmo:Hoard ;
 	skos:prefLabel ?findspot FILTER(langMatches(lang(?findspot), "EN")) }
OPTIONAL { ?object nmo:hasWeight ?weight }
OPTIONAL { ?object nmo:hasAxis ?axis }
OPTIONAL { ?object nmo:hasDiameter ?diameter }
OPTIONAL { ?object foaf:thumbnail ?comThumb }
OPTIONAL { ?object foaf:depiction ?comRef }
OPTIONAL { ?object nmo:hasObverse/foaf:thumbnail ?obvThumb }
OPTIONAL { ?object nmo:hasObverse ?obverse .
?obverse foaf:depiction ?obvRef }
OPTIONAL { ?object nmo:hasReverse/foaf:thumbnail ?revThumb }
OPTIONAL { ?object nmo:hasReverse ?reverse .
?reverse foaf:depiction ?revRef }}
ORDER BY ASC(?publisher) ASC(?collection)]]></xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'typeURI', $uri)), '&amp;output=xml')"/>					
				</xsl:variable>

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
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
