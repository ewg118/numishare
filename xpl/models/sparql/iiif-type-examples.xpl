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
				<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>				

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
				
				<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX void:	<http://rdfs.org/ns/void#>
PREFIX svcs:	<http://rdfs.org/sioc/services#>

SELECT ?object ?title ?identifier ?collection ?publisher ?dataset ?datasetTitle ?weight ?axis ?diameter ?obvService ?revService ?comService WHERE {
?object nmo:hasTypeSeriesItem <typeURI> ;
  rdf:type nmo:NumismaticObject ;
  dcterms:title ?title .
OPTIONAL { ?object dcterms:identifier ?identifier}
OPTIONAL { ?object nmo:hasCollection ?colUri .
?colUri skos:prefLabel ?collection FILTER(langMatches(lang(?collection), "EN"))}
?object void:inDataset ?dataset .
?dataset dcterms:publisher ?publisher ;
	dcterms:title ?datasetTitle FILTER (lang(?datasetTitle) = "" || langMatches(lang(?datasetTitle), "en")) .
OPTIONAL { ?object nmo:hasWeight ?weight }
OPTIONAL { ?object nmo:hasAxis ?axis }
OPTIONAL { ?object nmo:hasDiameter ?diameter }
{ ?object foaf:depiction ?comRef .
 ?comRef svcs:has_service ?comService}
UNION {
 	{ ?object nmo:hasObverse/foaf:depiction ?obvRef.
	 ?obvRef svcs:has_service ?obvService }
	{ ?object nmo:hasReverse/foaf:depiction ?revRef .
	 ?revRef svcs:has_service ?revService }
  }
} ORDER BY ASC(?publisher) ASC(?collection)]]></xsl:variable>

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
