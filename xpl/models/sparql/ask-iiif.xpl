<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki: ascertain whether there are physical objects with IIIF services connected to a coin type
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
	
	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>				
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_endpoint"/>
				
				<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX svcs:	<http://rdfs.org/sioc/services#>

ASK {
  ?object nmo:hasTypeSeriesItem <typeURI> ;
  	a nmo:NumismaticObject .
  {?object foaf:depiction ?comRef .
  ?comRef svcs:has_service ?comService}
  UNION {
 	{ ?object nmo:hasObverse/foaf:depiction ?obvRef.
	 ?obvRef svcs:has_service ?obvService }
	{ ?object nmo:hasReverse/foaf:depiction ?revRef .
	 ?revRef svcs:has_service ?revService }
  }
}]]></xsl:variable>
				
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
