<?xml version="1.0" encoding="UTF-8"?>
<!-- this stylesheet contains widgets to interact with external systems for use throughout Numishare, 
for example pulling data from the coin-type triplestore and SPARQL endpoint, Metis -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:exsl="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all">
	<xsl:include href="../functions.xsl"/>

	<xsl:template name="numishare:associatedObjects">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
			PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
			
			SELECT ?object ?title ?identifier ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef  WHERE {
			?object nm:type_series_item <typeUri>.
			?object a nm:coin .
			?object dcterms:title ?title .
			OPTIONAL { ?object dcterms:identifier ?identifier } .
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
			OPTIONAL { ?object foaf:depiction ?comRef }}
			ORDER BY ASC(?collection)]]>
		</xsl:variable>
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

	<xsl:template name="numishare:getImages">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
			PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
			
			SELECT ?object ?objectType ?identifier ?collection ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef ?type WHERE {
			<typeUris>
			 ?object rdf:type ?objectType .
			OPTIONAL { ?object dcterms:identifier ?identifier }
			OPTIONAL { ?object nm:collection ?colUri .
			?colUri skos:prefLabel ?collection 
			FILTER(langMatches(lang(?collection), "EN"))}		
			OPTIONAL { ?object nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?object nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?object nm:obverseReference ?obvRef }
			OPTIONAL { ?object nm:reverseReference ?revRef }
			OPTIONAL { ?object nm:type_series_item ?type }
			OPTIONAL { ?object foaf:thumbnail ?comThumb }
			OPTIONAL { ?object foaf:depiction ?comRef }
			]]>
		</xsl:variable>

		<xsl:variable name="template">
			<xsl:text><![CDATA[ { ?object nm:type_series_item <typeUri> }]]></xsl:text>
		</xsl:variable>

		<xsl:variable name="union">
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:if test="not(position()=1)">
					<xsl:text>UNION </xsl:text>
				</xsl:if>
				<xsl:value-of select="replace($template, 'typeUri', concat($baseUri, .))"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="filter">
			<xsl:text> FILTER(</xsl:text>
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:variable name="escapedId" select="replace(replace(replace(., '\)', '\\\\)'), '\(', '\\\\('), '\.', '\\\\.')"/>
				<xsl:text>regex(str(?type), "</xsl:text>
				<xsl:value-of select="$escapedId"/>
				<xsl:text>", "i")</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text> || </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:variable>

		<xsl:variable name="post">
			<xsl:value-of select="normalize-space(concat(replace($query, '&lt;typeUris&gt;', $union), $filter, '}'))"/>
		</xsl:variable>

		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri($post), '&amp;output=xml')"/>
		<xsl:copy-of select="document($service)/res:sparql"/>
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

				<!-- choose between between Metis (preferred) or internal links -->
				<xsl:apply-templates select="descendant::res:result[not(contains(res:binding[@name='objectType'], 'hoard'))]" mode="display"/>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template match="res:sparql" mode="results">
		<xsl:variable name="id" select="generate-id()"/>
		<xsl:variable name="count" select="count(descendant::res:result)"/>
		<xsl:variable name="coin-count"
			select="count(descendant::res:result[contains(res:binding[@name='objectType']/res:uri, 'coin')]) + count(descendant::res:result[not(child::res:binding[@name='objectType'])])"/>
		<xsl:variable name="hoard-count" select="count(descendant::res:result[contains(res:binding[@name='objectType']/res:uri, 'hoard')])"/>

		<!-- get images -->
		<xsl:apply-templates select="descendant::res:result[res:binding[contains(@name, 'rev') or contains(@name, 'obv')]]" mode="results">
			<xsl:with-param name="id" select="tokenize($uri, '/')[last()]"/>
		</xsl:apply-templates>
		<!-- object count -->
		<xsl:if test="$count &gt; 0">
			<br/>
			<xsl:if test="$coin-count &gt; 0">
				<xsl:value-of select="$coin-count"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$coin-count = 1">
						<xsl:value-of select="numishare:normalizeLabel('results_coin', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('results_coins', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$coin-count &gt; 0 and $hoard-count &gt; 0">
				<xsl:text> </xsl:text>
				<xsl:value-of select="numishare:normalizeLabel('results_and', $lang)"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="$hoard-count &gt; 0">
				<xsl:value-of select="$hoard-count"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$hoard-count = 1">
						<xsl:value-of select="numishare:normalizeLabel('results_hoard', $lang)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="numishare:normalizeLabel('results_hoards', $lang)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:sparql" mode="kml">
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="json">
		<xsl:if test="count(descendant::res:result/res:binding[@name='findspot']) &gt; 0">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="json"/>
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
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- reverse-->
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- combined -->
				<xsl:if test="string(res:binding[@name='comRef']/res:uri) and not(string(res:binding[@name='comThumb']/res:uri))">
					<a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}"
						title="Image of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
						<img class="gi" src="{res:binding[@name='comRef']/res:uri}" style="max-width:240px"/>
					</a>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="results">
		<xsl:param name="id"/>
		<xsl:variable name="position" select="position()"/>
		<!-- obverse -->
		<xsl:choose>
			<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{res:binding[@name='obvThumb']/res:uri}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
				<img src="{res:binding[@name='obvThumb']/res:uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<img src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px">
						<xsl:if test="$position &gt; 1">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
					</img>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- reverse-->
		<xsl:choose>
			<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
					title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{res:binding[@name='revThumb']/res:uri}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
				<img src="{res:binding[@name='revThumb']/res:uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
				<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
					<img src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px">
						<xsl:if test="$position &gt; 1">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
					</img>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- combined -->
		<xsl:if test="string(res:binding[@name='comRef']/res:uri) and not(string(res:binding[@name='comThumb']/res:uri))">
			<a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}"
				title="Image of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
				<img src="{res:binding[@name='comRef']/res:uri}" style="max-width:240px">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</a>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:binding[@name='findspot']" mode="json">
		<xsl:variable name="coordinates">
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="contains(child::res:uri, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:uri, 'geonames.org/'), '/')"/>
					<xsl:if test="number($geonameId)">
						<xsl:variable name="geonames_data" as="element()*">
							<xml><xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/></xml>
						</xsl:variable>
						<xsl:if test="string($geonames_data//lng) and string($geonames_data//lng)">
							<xsl:variable name="coords" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
							<xsl:value-of select="$coords"/>
						</xsl:if>
					</xsl:if>
				</xsl:when>
				<xsl:when test="string(res:literal)">
					<xsl:value-of select="res:literal"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:value-of select="parent::node()/res:binding[@name='title']/res:literal"/>
		</xsl:variable>
		<xsl:variable name="description">
			<![CDATA[
          					<span><a href=']]><xsl:value-of select="parent::node()/res:binding[@name='object']/res:uri"/><![CDATA[' target='_blank'>]]><xsl:value-of
				select="parent::node()/res:binding[@name='title']/res:literal"/><![CDATA[</a>]]>
			<xsl:if test="string(parent::node()/res:binding[@name='burial']/res:literal)">
				<![CDATA[- closing date: ]]><xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
			</xsl:if>
			<![CDATA[</span>
        				]]>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<xsl:variable name="start">
			<xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
		</xsl:variable>
		<!-- output --> { <xsl:if test="string($coordinates)">"point": {"lon": <xsl:value-of select="tokenize($coordinates, ',')[1]"/>, "lat": <xsl:value-of select="tokenize($coordinates, ',')[2]"
			/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", "start": "<xsl:value-of select="$start"/>", <xsl:if test="string($end)">"end": "<xsl:value-of select="$end"/>",</xsl:if>
		"options": { "theme": "<xsl:value-of select="$theme"/>", "description": "<xsl:value-of select="normalize-space($description)"/>" } }<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:binding[@name='findspot']" mode="kml">
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="parent::node()/res:binding[@name='title']/res:literal"/>
			</name>
			<description>
				<![CDATA[
          					<span><a href="]]><xsl:value-of select="parent::node()/res:binding[@name='uri']/res:uri"/><![CDATA[" target="_blank">]]><xsl:value-of
					select="parent::node()/res:binding[@name='title']/res:literal"/><![CDATA[</a>]]>
				<xsl:if test="string(parent::node()/res:binding[@name='burial']/res:literal)">
					<![CDATA[- closing date: ]]><xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
				</xsl:if>
				<![CDATA[</span>
        				]]>
			</description>

			<styleUrl>#mapped</styleUrl>
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="contains(child::res:uri, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:uri, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="string(res:literal)">
					<Point>
						<coordinates>
							<xsl:value-of select="res:literal"/>
						</coordinates>
					</Point>
				</xsl:when>
			</xsl:choose>
			<!-- add timespan -->
			<xsl:if test="string(parent::node()/res:binding[@name='burial']/res:literal)">
				<TimeStamp>
					<when>
						<xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
					</when>
				</TimeStamp>
			</xsl:if>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
