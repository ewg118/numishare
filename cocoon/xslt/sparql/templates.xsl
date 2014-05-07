<?xml version="1.0" encoding="UTF-8"?>
<!-- this stylesheet contains widgets to interact with external systems for use throughout Numishare, 
for example pulling data from the coin-type triplestore and SPARQL endpoint, Metis -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all">
	<xsl:include href="../functions.xsl"/>

	<xsl:template name="numishare:associatedObjects">
		<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>

SELECT ?object ?title ?identifier ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef  WHERE {
?object nm:type_series_item <typeUri>.
?object a nm:coin .
?object dcterms:title ?title .
OPTIONAL { ?object dcterms:identifier ?identifier}
OPTIONAL { ?object nm:collection ?colUri .
?colUri skos:prefLabel ?collection 
FILTER(langMatches(lang(?collection), "EN"))}
OPTIONAL { ?object nm:weight ?weight }
OPTIONAL { ?object nm:axis ?axis }
OPTIONAL { ?object nm:diameter ?diameter }
OPTIONAL { ?object nm:obverseThumbnail ?obvThumb }
OPTIONAL { ?object nm:reverseThumbnail ?revThumb }
OPTIONAL { ?object nm:obverseReference ?obvRef }
OPTIONAL { ?object nm:reverseReference ?revRef }
OPTIONAL { ?object foaf:thumbnail ?comThumb }
OPTIONAL { ?object foaf:depiction ?comRef }
OPTIONAL { ?object nm:obverse ?obverse .
?obverse foaf:thumbnail ?obvThumb }
OPTIONAL { ?object nm:obverse ?obverse .
?obverse foaf:depiction ?obvRef }
OPTIONAL { ?object nm:reverse ?reverse .
?reverse foaf:thumbnail ?revThumb }
OPTIONAL { ?object nm:reverse ?reverse .
?reverse foaf:depiction ?revRef }}
ORDER BY ASC(?collection)]]></xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="display"/>
	</xsl:template>

	<xsl:template name="numishare:getFindspots">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
			
			SELECT ?object ?uri ?title ?publisher ?findspot ?lat ?long ?objectType ?burial WHERE {
			?object nm:type_series_item <typeUri>.
			?object dcterms:title ?title .
			?object dcterms:publisher ?publisher .
			?object nm:findspot ?findspot .
			?findspot geo:lat ?lat .
			?findspot geo:long ?long .
			OPTIONAL { ?object rdf:type ?objectType }
			OPTIONAL { ?object nm:closing_date ?burial }}]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="kml"/>
	</xsl:template>

	<xsl:template name="numishare:getJsonFindspots">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
			
			SELECT ?object ?uri ?title ?publisher ?findspot ?objectType ?burial ?lat ?long WHERE {
			?object nm:type_series_item <typeUri>.
			?object dcterms:title ?title .
			?object dcterms:publisher ?publisher .
			?object nm:findspot ?findspot .
			?findspot geo:lat ?lat .
			?findspot geo:long ?long .
			OPTIONAL { ?object rdf:type ?objectType }
			OPTIONAL { ?object nm:closing_date ?burial }}]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="json"/>
	</xsl:template>

	<xsl:template name="numishare:solrFields">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
			
			SELECT ?object ?title ?findspot ?lat ?long WHERE {
			?object nm:type_series_item <typeUri> .
			?object dcterms:title ?title .			
			?object nm:findspot ?findspot .
			?findspot geo:lat ?lat .
			?findspot geo:long ?long }
			]]>
		</xsl:variable>

		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
		<xsl:copy-of select="document($service)/res:sparql"/>
	</xsl:template>

	<xsl:template name="numishare:avgMeasurement">
		<xsl:variable name="api">
			<xsl:choose>
				<xsl:when test="$measurement='axis'">avgAxis</xsl:when>
				<xsl:when test="$measurement='diameter'">avgDiameter</xsl:when>
				<xsl:when test="$measurement='weight'">avgWeight</xsl:when>
			</xsl:choose>
		</xsl:variable>


		<xsl:variable name="service" select="concat('http://nomisma.org/apis/', $api, '?constraints=', encode-for-uri($constraints))"/>
		<xsl:value-of select="format-number(document($service)//response, '#.00')"/>
	</xsl:template>

	<xsl:template name="numishare:facets">
		<xsl:variable name="query">
			<xsl:choose>
				<xsl:when test="$field = 'nm:collection'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
					SELECT DISTINCT ?val ?label WHERE {
					?type dcterms:isPartOf <TYPE_SERIES>.
					?object nm:type_series_item ?type .
					?object nm:collection ?val .
					?val skos:prefLabel ?label
					FILTER(langMatches(lang(?label), "LANG"))} 
					ORDER BY asc(?label)
					]]>
				</xsl:when>
				<xsl:otherwise>
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
					SELECT DISTINCT ?val ?label WHERE {
					?object dcterms:isPartOf <TYPE_SERIES>.
					?object FIELD ?val .
					?val skos:prefLabel ?label
					FILTER(langMatches(lang(?label), "LANG"))} 
					ORDER BY asc(?label)
					]]>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="langStr" select="if (string($lang)) then $lang else 'en'"/>
		<xsl:variable name="service"
			select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace(replace(replace($query, 'TYPE_SERIES', //config/type_series), 'LANG', $langStr), 'FIELD', $field))), '&amp;output=xml')"/>

		<select class="search_text form-control">
			<option value="">Select option from list...</option>
			<xsl:for-each select="document($service)//res:result">
				<option value="{res:binding[@name='val']/res:uri}" class="term">
					<xsl:value-of select="res:binding[@name='label']/res:literal"/>
				</option>
			</xsl:for-each>
		</select>

	</xsl:template>

	<!-- **************** PROCESS SPARQL RESPONSE ****************-->
	<xsl:template match="res:sparql" mode="display">
		<xsl:variable name="coin-count"
			select="count(descendant::res:result[contains(res:binding[@name='objectType']/res:uri, 'coin')]) + count(descendant::res:result[not(child::res:binding[@name='objectType'])])"/>

		<xsl:if test="$coin-count &gt; 0">
			<div class="objects">
				<h2>
					<xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
				</h2>

				<!-- choose between between nomisma (preferred) or internal links -->
				<xsl:apply-templates select="descendant::res:result[not(contains(res:binding[@name='objectType'], 'hoard'))]" mode="display"/>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template match="res:sparql" mode="kml">
		<xsl:apply-templates select="descendant::res:result" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="json">
		<xsl:if test="count(descendant::res:result/res:binding[@name='findspot']) &gt; 0">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="descendant::res:result" mode="json"/>
	</xsl:template>


	<!-- **************** PROCESS INDIVIDUAL RESULTS ****************-->
	<xsl:template match="res:result" mode="display">
		<div class="g_doc col-md-4">
			<span class="result_link">
				<a href="{res:binding[@name='object']/res:uri}" target="_blank">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</span>
			<dl class="dl-horizontal">
				<xsl:if test="res:binding[@name='collection']/res:literal">
					<dt>
						<xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="res:binding[@name='collection']/res:literal"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='axis']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='axis']/res:literal)"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='diameter']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='diameter']/res:literal)"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='weight']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='weight']/res:literal)"/>
					</dd>
				</xsl:if>
			</dl>
			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- reverse-->
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- combined -->
				<xsl:if test="string(res:binding[@name='comRef']/res:uri) and not(string(res:binding[@name='comThumb']/res:uri))">
					<a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}"
						title="Image of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
						<img class="gi" src="{res:binding[@name='comRef']/res:uri}" style="max-width:240px"/>
					</a>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="json">
		<xsl:variable name="closing_date" select="res:binding[@name='burial']/res:literal"/>
		<xsl:variable name="lat" select="res:binding[@name='lat']/res:literal"/>
		<xsl:variable name="long" select="res:binding[@name='long']/res:literal"/>
		<xsl:variable name="title">
			<xsl:value-of select="res:binding[@name='title']/res:literal"/>
		</xsl:variable>
		<xsl:variable name="description">
			<![CDATA[<dl class='dl-horizontal'><dt>URL</dt><dd><a href=']]><xsl:value-of select="res:binding[@name='object']/res:uri"/><![CDATA['>]]><xsl:value-of
				select="res:binding[@name='object']/res:uri"/><![CDATA[</a></dd>]]>
			<xsl:if test="string($closing_date)">
				<![CDATA[<dt>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[</dt><dd>]]><xsl:value-of select="numishare:normalizeYear(number($closing_date))"
				/><![CDATA[</dd>]]>
			</xsl:if>
			<![CDATA[</dl>]]>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<!-- output --> { <xsl:if test="string($lat) and string($long)">"point": {"lon": <xsl:value-of select="$long"/>, "lat": <xsl:value-of select="$lat"/>},</xsl:if> "title": "<xsl:value-of
			select="$title"/>", "start": "<xsl:value-of select="$closing_date"/>", "options": { "theme": "<xsl:value-of select="$theme"/>", "description": "<xsl:value-of
			select="normalize-space($description)"/>" } }<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:result" mode="kml">
		<xsl:variable name="closing_date" select="res:binding[@name='burial']/res:literal"/>
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="res:binding[@name='title']/res:literal"/>
			</name>
			<description>
				<![CDATA[
          					<dl class='dl-horizontal'><dt>URL</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='findspot']/res:uri"/><![CDATA[" target="_blank">]]><xsl:value-of
					select="res:binding[@name='title']/res:literal"/><![CDATA[</a></dd>]]>
				<xsl:if test="number($closing_date) castable as xs:integer">
					<![CDATA[<dt>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[</dt><dd>]]><xsl:value-of select="number($closing_date)"/><![CDATA[</dd>]]>
				</xsl:if>
				<![CDATA[</dl>
        				]]>
			</description>

			<styleUrl>#mapped</styleUrl>
			<!-- add placemark -->
			<Point>
				<coordinates>
					<xsl:value-of select="concat(res:binding[@name='long']/res:literal, ',', res:binding[@name='lat']/res:literal)"/>
				</coordinates>
			</Point>
			<!-- add timespan -->
			<xsl:if test="string($closing_date)">
				<TimeStamp>
					<when>
						<xsl:value-of select="number($closing_date)"/>
					</when>
				</TimeStamp>
			</xsl:if>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
