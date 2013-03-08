<?xml version="1.0" encoding="UTF-8"?>
<!-- this stylesheet contains widgets to interact with external systems for use throughout Numishare, 
for example pulling data from the coin-type triplestore and SPARQL endpoint, Metis -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:exsl="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all">
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="template"/>
	<xsl:param name="uri"/>
	<xsl:param name="lang"/>

	<!-- config variables -->
	<xsl:variable name="endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/config/geonames_api_key"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$template = 'results'">
				<xsl:call-template name="numishare:getImages"/>
			</xsl:when>
			<xsl:when test="$template = 'display'">
				<xsl:call-template name="numishare:associatedObjects"/>
			</xsl:when>
			<xsl:when test="$template = 'kml'">
				<xsl:call-template name="numishare:getFindspots"/>
			</xsl:when>
			<xsl:when test="$template = 'json'">
				<xsl:call-template name="numishare:getJsonFindspots"/>
			</xsl:when>
			<xsl:when test="$template = 'solr'">
				<xsl:call-template name="numishare:solrFields"/>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="numishare:associatedObjects">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			
			SELECT ?annotation ?uri ?title ?publisher ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?findspot ?numismatic_term WHERE {
			?annotation nm:type_series_item <typeUri>.
			?annotation dcterms:title ?title .
			?annotation dcterms:publisher ?publisher .
			OPTIONAL { ?annotation nm:collection ?collection } .
			OPTIONAL { ?annotation nm:weight ?weight }
			OPTIONAL { ?annotation nm:axis ?axis }
			OPTIONAL { ?annotation nm:diameter ?diameter }
			OPTIONAL { ?annotation nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?annotation nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?annotation nm:obverseReference ?obvRef }
			OPTIONAL { ?annotation nm:reverseReference ?revRef }
			OPTIONAL { ?annotation nm:findspot ?findspot }
			OPTIONAL { ?annotation nm:numismatic_term ?numismatic_term }}
			ORDER BY ASC(?publisher)]]>
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
			
			SELECT ?annotation ?uri ?title ?publisher ?findspot ?numismatic_term ?burial WHERE {
			?annotation nm:type_series_item <typeUri>.
			?annotation dcterms:title ?title .
			?annotation dcterms:publisher ?publisher .
			?annotation nm:findspot ?findspot .
			OPTIONAL { ?annotation nm:numismatic_term ?numismatic_term }
			OPTIONAL { ?annotation nm:closing_date ?burial }}]]>
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
			
			SELECT ?annotation ?uri ?title ?publisher ?findspot ?numismatic_term ?burial WHERE {
			?annotation nm:type_series_item <typeUri>.
			?annotation dcterms:title ?title .
			?annotation dcterms:publisher ?publisher .
			?annotation nm:findspot ?findspot .
			OPTIONAL { ?annotation nm:numismatic_term ?numismatic_term }
			OPTIONAL { ?annotation nm:closing_date ?burial }}]]>
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
			
			SELECT ?annotation ?uri ?publisher ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?findspot ?numismatic_term  WHERE {
			?annotation nm:type_series_item<typeUri>.
			?annotation dcterms:publisher ?publisher .
			OPTIONAL { ?annotation nm:collection ?collection } .
			OPTIONAL { ?annotation nm:weight ?weight }
			OPTIONAL { ?annotation nm:axis ?axis }
			OPTIONAL { ?annotation nm:diameter ?diameter }
			OPTIONAL { ?annotation nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?annotation nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?annotation nm:obverseReference ?obvRef }
			OPTIONAL { ?annotation nm:reverseReference ?revRef }
			OPTIONAL { ?annotation nm:findspot ?findspot }
			OPTIONAL { ?annotation nm:numismatic_term ?numismatic_term }}
			ORDER BY ASC(?publisher)]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>

		<div>
			<xsl:apply-templates select="document($service)/res:sparql" mode="results"/>
		</div>

	</xsl:template>

	<xsl:template name="numishare:solrFields">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			
			SELECT ?annotation ?uri ?title ?publisher ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef ?findspot ?numismatic_term  WHERE {
			?annotation nm:type_series_item <typeUri>.
			?annotation dcterms:title ?title .
			?annotation dcterms:publisher ?publisher .
			OPTIONAL { ?annotation nm:collection ?collection } .
			OPTIONAL { ?annotation nm:weight ?weight }
			OPTIONAL { ?annotation nm:axis ?axis }
			OPTIONAL { ?annotation nm:diameter ?diameter }
			OPTIONAL { ?annotation nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?annotation nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?annotation nm:obverseReference ?obvRef }
			OPTIONAL { ?annotation nm:reverseReference ?revRef }
			OPTIONAL { ?annotation nm:findspot ?findspot }
			OPTIONAL { ?annotation nm:numismatic_term ?numismatic_term }}
			ORDER BY ASC(?publisher)]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="solr"/>
	</xsl:template>

	<!-- **************** PROCESS SPARQL RESPONSE ****************-->

	<xsl:template match="res:sparql" mode="display">
		<xsl:variable name="coin-count"
			select="count(descendant::res:result[contains(res:binding[@name='numismatic_term']/res:uri, 'coin')]) + count(descendant::res:result[not(child::res:binding[@name='numismatic_term'])])"/>

		<xsl:if test="$coin-count &gt; 0">
			<div class="objects">
				<h2>Examples of this type</h2>

				<!-- choose between between Metis (preferred) or internal links -->
				<xsl:apply-templates select="descendant::res:result[not(contains(res:binding[@name='numismatic_term'], 'hoard'))]" mode="display"/>
			</div>
		</xsl:if>

	</xsl:template>

	<xsl:template match="res:sparql" mode="results">
		<xsl:variable name="id" select="generate-id()"/>
		<xsl:variable name="count" select="count(descendant::res:result)"/>
		<xsl:variable name="coin-count"
			select="count(descendant::res:result[contains(res:binding[@name='numismatic_term']/res:uri, 'coin')]) + count(descendant::res:result[not(child::res:binding[@name='numismatic_term'])])"/>
		<xsl:variable name="hoard-count" select="count(descendant::res:result[contains(res:binding[@name='numismatic_term']/res:uri, 'hoard')])"/>

		<!-- get images -->
		<xsl:apply-templates select="descendant::res:result[res:binding[contains(@name, 'rev') or contains(@name, 'obv')]]" mode="results">
			<xsl:with-param name="id" select="tokenize($uri, '/')[last()]"/>
		</xsl:apply-templates>
		<!-- object count -->
		<xsl:if test="$count &gt; 0">
			<br/>
			<xsl:if test="$count != $coin-count and $count != $hoard-count">
				<xsl:value-of select="concat($count, if($count = 1) then ' associated object' else ' associated objects')"/>
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:if test="$coin-count &gt; 0">
				<xsl:value-of select="concat($coin-count, if($coin-count = 1) then ' coin' else ' coins')"/>
			</xsl:if>
			<xsl:if test="$coin-count &gt; 0 and $hoard-count &gt; 0">
				<xsl:text> and </xsl:text>
			</xsl:if>
			<xsl:if test="$hoard-count &gt; 0">
				<xsl:value-of select="concat($hoard-count, if($hoard-count = 1) then ' hoard' else ' hoards')"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:sparql" mode="kml">
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="solr">
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="solr"/>
	</xsl:template>
	
	<xsl:template match="res:sparql" mode="json">
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="json"/>
	</xsl:template>


	<!-- **************** PROCESS INDIVIDUAL RESULTS ****************-->
	<xsl:template match="res:result" mode="display">
		<div class="g_doc">
			<span class="result_link">
				<a href="{res:binding[@name='uri']/res:uri}" target="_blank">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</span>
			<dl>
				<xsl:if test="res:binding[@name='collection']/res:literal">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('collection', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="res:binding[@name='collection']/res:literal"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='axis']/res:literal)">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('axis', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='axis']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='diameter']/res:literal)">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='diameter']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='weight']/res:literal)">
					<div>
						<dt><xsl:value-of select="numishare:regularize_node('weight', $lang)"/>: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='weight']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
			</dl>
			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}"
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
							<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- reverse-->
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
							<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}">
							<img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
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
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
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
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
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
					title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
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
					title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='publisher']/res:literal}">
					<img src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px">
						<xsl:if test="$position &gt; 1">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
					</img>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="res:binding[@name='findspot']" mode="json">		
		<xsl:variable name="coordinates">
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="contains(child::res:uri, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:uri, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
					<xsl:value-of select="$coordinates"/>
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
          					<span><a href="]]><xsl:value-of select="parent::node()/res:binding[@name='uri']/res:uri"/><![CDATA[" target="_blank">]]><xsl:value-of
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
		
		<!-- output --> { <xsl:if test="not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[2]"/>, "lat": <xsl:value-of
			select="tokenize($coordinates, '\|')[1]"/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", "start": "<xsl:value-of select="$start"/>", <xsl:if test="string($end)">"end":
				"<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>", "description": "<xsl:value-of select="$description"/>" } } 
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

	<xsl:template match="res:binding[@name='findspot']" mode="solr">
		<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
		<xsl:choose>
			<xsl:when test="contains(child::res:uri, 'geonames')">
				<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:uri, 'geonames.org/'), '/')"/>
				<xsl:variable name="geonames_data" as="element()*">
					<results>
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					</results>
				</xsl:variable>
				<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
				
				<field name="findspot_geo">
					<xsl:value-of select="parent::node()/res:binding[@name='title']/res:literal"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="child::res:uri"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$coordinates"/>
				</field>
				
				<!-- hierarchy -->
			<!--	<xsl:variable name="hierarchy">
					<xsl:value-of select="$geonames_data//countryName"/>
					<xsl:for-each select="$geonames_data//*[starts-with(local-name(), 'adminName')]">
						<xsl:sort select="local-name()"/>
						<xsl:if test="string-length(.) &gt; 0">
							<xsl:text>|</xsl:text>
							<xsl:value-of select="."/>
						</xsl:if>		
					</xsl:for-each>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$geonames_data//name"/>
				</xsl:variable>
				
				<xsl:for-each select="tokenize($hierarchy, '\|')">
					<field name="findspot_hier">
						<xsl:value-of select="concat('L', position(), '|', .)"/>
					</field>
					<field name="findspot_text">
						<xsl:value-of select="."/>
					</field>
				</xsl:for-each>-->
			</xsl:when>
			<xsl:when test="string(res:literal)">
				<field name="findspot_geo">
					<xsl:value-of select="parent::node()/res:binding[@name='title']/res:literal"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="child::res:uri"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="res:literal"/>
				</field>
			</xsl:when>
		</xsl:choose>

		<field name="findspot_facet">
			<xsl:value-of select="parent::node()/res:binding[@name='title']/res:literal"/>
		</field>
		<xsl:if test="string(child::res:uri)">
			<field name="findspot_uri">
				<xsl:value-of select="child::res:uri"/>
			</field>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
