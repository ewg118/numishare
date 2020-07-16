<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: April 2019
	Function: Execute a series of SPARQL queries to get the count and sample images for each identifier listed in the Solr-based browse page.
		This is intended to be used when the SPARQL endpoint defined in the config differs from Nomisma.org	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- evaluate the Solr results and use Solr recordId fields and optional uri spaces -->	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:template match="/">
					<identifiers>
						<xsl:choose>
							<xsl:when test="doc('input:config-xml')/config/union_type_catalog/@enabled = true()">
								<xsl:for-each select="descendant::doc">
									<identifier>
										<xsl:value-of select="concat(str[@name='uri_space'], str[@name='recordId'])"/>
									</identifier>
								</xsl:for-each>								
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="uri_space" select="doc('input:config-xml')/config/uri_space"/>
								
								<xsl:for-each select="descendant::doc">
									<identifier>
										<xsl:value-of select="concat($uri_space, str[@name='recordId'])"/>
									</identifier>
								</xsl:for-each>	
							</xsl:otherwise>
						</xsl:choose>
					</identifiers>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="identifiers"/>
	</p:processor>
	
	<p:for-each href="#identifiers" select="//identifier" root="response" id="response">
		<p:processor name="oxf:identity">
			<p:input name="data" href="current()"/>
			<p:output name="data" id="id"/>
		</p:processor>
		
		<!-- execute SPARQL for hoard/object counts -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="config-xml" href=" #config"/>
			<p:input name="data" href="current()"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
					<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_endpoint"/>
					<xsl:variable name="query">
						<![CDATA[PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?type (count(?type) as ?count) WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { <typeUri> skos:exactMatch ?match .
?object nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeUri> .
?broader skos:exactMatch ?match .
?object nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
UNION { ?contents a dcmitype:Collection ; 
  nmo:hasTypeSeriesItem <typeUri> .
?object dcterms:tableOfContents ?contents }
?object rdf:type ?type .
} GROUP BY ?type]]></xsl:variable>
					
					<xsl:template match="/">
						<xsl:variable name="uri" select="."/>
						<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
						
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
			<p:output name="data" id="count-url-generator-config"/>
		</p:processor>
		
		<!-- query SPARQL -->
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#count-url-generator-config"/>
			<p:output name="data" id="counts"/>
		</p:processor>
		
		<!-- execute SPARQL query for images -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="config-xml" href=" #config"/>
			<p:input name="data" href="current()"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">	
					<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_endpoint"/>
					<xsl:variable name="query">
						<![CDATA[PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX void:	<http://rdfs.org/ns/void#>
SELECT DISTINCT ?object ?identifier ?collection ?datasetTitle ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { <typeUri> skos:exactMatch ?match .
?object nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeUri> .
?broader skos:exactMatch ?match .
?object nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
OPTIONAL { ?object dcterms:identifier ?identifier }
OPTIONAL { ?object nmo:hasCollection ?colUri .
?colUri skos:prefLabel ?collection FILTER(langMatches(lang(?collection), "EN"))}
?object void:inDataset ?dataset .
?dataset dcterms:title ?datasetTitle FILTER (lang(?datasetTitle) = "" || langMatches(lang(?datasetTitle), "en")) .
OPTIONAL { ?object foaf:thumbnail ?comThumb }
OPTIONAL { ?object foaf:depiction ?comRef }
OPTIONAL { ?object nmo:hasObverse/foaf:thumbnail ?obvThumb }
OPTIONAL { ?object nmo:hasObverse/foaf:depiction ?obvRef }
OPTIONAL { ?object nmo:hasReverse/foaf:thumbnail ?revThumb }
OPTIONAL { ?object nmo:hasReverse/foaf:depiction ?revRef }
} HAVING (isURI(?comThumb) || isURI(?comRef) || isURI(?obvThumb) || isURI(?obvRef) || isURI(?revThumb) || isURI(?revRef)) ORDER BY ASC(?datasetTitle) LIMIT 5]]></xsl:variable>
					
					<xsl:template match="/">
						<xsl:variable name="uri" select="."/>
						<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
						
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
			<p:output name="data" id="images-url-generator-config"/>
		</p:processor>
		
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#images-url-generator-config"/>
			<p:output name="data" id="images"/>
		</p:processor>
		
		<p:processor name="oxf:identity">
			<p:input name="data" href="aggregate('content', #id, #counts, #images)"/>
			<p:output name="data" ref="response"/>
		</p:processor>				
	</p:for-each>
	
	<!-- return aggregated SPARQL/XML response -->
	<p:processor name="oxf:identity">
		<p:input name="data" href="#response"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
