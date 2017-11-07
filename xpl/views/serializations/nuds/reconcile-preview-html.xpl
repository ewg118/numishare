<?xml version="1.0" encoding="UTF-8"?>
<!--
	Return the HTML preview snippet with ?id parameter for Open Refine reconciliation	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- execuate a SPARQL query for one associated coin -->
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
PREFIX edm: <http://www.europeana.eu/schemas/edm/>

SELECT ?object ?obvThumb ?revThumb ?comRef WHERE {
?object nmo:hasTypeSeriesItem <typeURI> ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasCollection ?collection.
{?object foaf:depiction ?comRef }
UNION{ ?object nmo:hasObverse/foaf:thumbnail ?obvThumb .
      ?object nmo:hasReverse/foaf:thumbnail ?revThumb }
} ORDER BY ?collection LIMIT 1]]></xsl:variable>
				
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
		<p:output name="data" id="sparql-response"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="sparql" href="#sparql-response"/>
		<p:input name="data" href="aggregate('content', #config, #data)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/nuds/reconcile-preview-html.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
