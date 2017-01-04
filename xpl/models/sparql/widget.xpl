<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:include href="../../../ui/xslt/functions.xsl"/>
				<!-- URL params -->
				<xsl:param name="template" select="doc('input:request')/request/parameters/parameter[name='template']/value"/>
				<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
				<xsl:param name="lang">
					<xsl:choose>
						<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='lang']/value)">
							<xsl:if test="//config/languages/language[@code=doc('input:request')/request/parameters/parameter[name='lang']/value][@enabled=true()]">
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
							</xsl:if>
						</xsl:when>
						<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
							<xsl:variable name="primaryLang" select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
							
							<xsl:if test="//config/languages/language[@code=$primaryLang][@enabled=true()]">
								<xsl:value-of select="$primaryLang"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:param>
				<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
				<xsl:param name="baseUri" select="doc('input:request')/request/parameters/parameter[name='baseUri']/value"/>
				<xsl:param name="constraints" select="doc('input:request')/request/parameters/parameter[name='constraints']/value"/>
				<xsl:param name="field" select="doc('input:request')/request/parameters/parameter[name='field']/value"/>
				<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name='measurement']/value"/>
				<xsl:param name="subtype" select="doc('input:request')/request/parameters/parameter[name='subtype']/value"/>
				<xsl:variable name="api">
					<xsl:choose>
						<xsl:when test="$measurement='axis'">avgAxis</xsl:when>
						<xsl:when test="$measurement='diameter'">avgDiameter</xsl:when>
						<xsl:when test="$measurement='weight'">avgWeight</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="langStr" select="if (string($lang)) then $lang else 'en'"/>

				<!-- config variables -->
				<xsl:variable name="endpoint" select="/config/sparql_endpoint"/>

				<xsl:variable name="query">
					<xsl:choose>						
						<xsl:when test="$template = 'kml'"><![CDATA[ PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>

SELECT ?object ?title ?findspot ?hoard ?placeName ?hoardLabel ?lat ?long ?type ?burial WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?contents a dcmitype:Collection ; 
  nmo:hasTypeSeriesItem <typeUri> .
?object dcterms:tableOfContents ?contents }
?object dcterms:title ?title .			
{ ?object nmo:hasFindspot ?findspot }
  UNION { ?object dcterms:isPartOf ?hoard .
        ?hoard a nmo:Hoard ;
        skos:prefLabel ?hoardLabel ;
        nmo:hasFindspot ?findspot .
   		OPTIONAL {?hoard nmo:hasClosingDate ?burial . FILTER isLiteral(?burial)}
        OPTIONAL {?hoard nmo:hasClosingDate ?closing .
                 ?closing nmo:hasEndDate ?burial}}
?findspot geo:lat ?lat .
?findspot geo:long ?long .
OPTIONAL {?findspot foaf:name ?placeName}
OPTIONAL {?findspot rdfs:label ?placeName}
OPTIONAL {?findspot skos:prefLabel ?placeName FILTER(langMatches(lang(?placeName), "en"))}
OPTIONAL { ?object rdf:type ?type } 
OPTIONAL { ?object nmo:hasClosingDate ?burial . FILTER isLiteral(?burial) }}]]>
						</xsl:when>						
						<xsl:when test="$template = 'json'"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>

SELECT ?object ?title ?findspot ?hoard ?placeName ?hoardLabel ?lat ?long ?type ?burial WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?contents a dcmitype:Collection ; 
  nmo:hasTypeSeriesItem <typeUri> .
?object dcterms:tableOfContents ?contents }
?object dcterms:title ?title .			
{ ?object nmo:hasFindspot ?findspot }
  UNION { ?object dcterms:isPartOf ?hoard .
        ?hoard a nmo:Hoard ;
        skos:prefLabel ?hoardLabel ;
        nmo:hasFindspot ?findspot .
   		OPTIONAL {?hoard nmo:hasClosingDate ?burial . FILTER isLiteral(?burial)}
        OPTIONAL {?hoard nmo:hasClosingDate ?closing .
                 ?closing nmo:hasEndDate ?burial}}
?findspot geo:lat ?lat .
?findspot geo:long ?long .
OPTIONAL {?findspot foaf:name ?placeName}
OPTIONAL {?findspot rdfs:label ?placeName}
OPTIONAL {?findspot skos:prefLabel ?placeName FILTER(langMatches(lang(?placeName), "en"))}
OPTIONAL { ?object rdf:type ?type } 
OPTIONAL { ?object nmo:hasClosingDate ?burial . FILTER isLiteral(?burial) }}]]>
						</xsl:when>
						<xsl:when test="$template = 'solr'"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?findspot ?findspotLabel  ?lat ?long WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?contents a dcmitype:Collection ; 
  nmo:hasTypeSeriesItem <typeUri> .
?object dcterms:tableOfContents ?contents }
?object dcterms:title ?title .			
{ ?object nmo:hasFindspot ?findspot }
UNION {?object dcterms:isPartOf ?hoard .
 ?hoard a nmo:Hoard ; nmo:hasFindspot ?findspot }
OPTIONAL {?findspot foaf:name ?findspotLabel}
OPTIONAL {?findspot rdfs:label ?findspotLabel}
?findspot geo:lat ?lat .
?findspot geo:long ?long }]]>
						</xsl:when>
						<xsl:when test="$template = 'facets'">
							<xsl:choose>
								<xsl:when test="$field = 'nmo:hasCollection'"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
SELECT DISTINCT ?val ?label WHERE {
?type dcterms:source <TYPE_SERIES>.
?object nmo:hasTypeSeriesItem ?type .
?object nmo:hasCollection ?val .
?val skos:prefLabel ?label
FILTER(langMatches(lang(?label), "LANG"))} 
ORDER BY asc(?label)
]]>
								</xsl:when>
								<xsl:otherwise><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
SELECT DISTINCT ?val ?label WHERE {
?object dcterms:source <TYPE_SERIES>.
?object FIELD ?val .
?val skos:prefLabel ?label
FILTER(langMatches(lang(?label), "LANG"))} 
ORDER BY asc(?label)
]]>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="$template = 'avgMeasurement'">
							<xsl:value-of select="concat('http://nomisma.org/apis/', $api, '?constraints=', encode-for-uri($constraints))"/>
						</xsl:when>
						<xsl:when test="$template = 'facets'">
							<xsl:value-of select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace(replace(replace($query, 'TYPE_SERIES', /config/type_series), 'LANG', $langStr), 'FIELD', $field))), '&amp;output=xml')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
						</xsl:otherwise>
					</xsl:choose>
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
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
