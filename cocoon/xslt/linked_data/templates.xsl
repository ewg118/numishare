<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl nm nuds nh xlink" xmlns:exsl="http://exslt.org/common"
	xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:georss="http://www.georss.org/georss" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oac="http://www.openannotation.org/ns/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:gx="http://www.google.com/kml/ext/2.2" version="2.0">

	<!-- ************** OBJECT-TO-RDF **************** -->
	<xsl:template name="rdf">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="pelagios"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="pelagios"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$mode='ctype'">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="ctype"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="ctype"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:apply-templates select="/content/nuds:nuds" mode="cidoc"/>
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:apply-templates select="/content/nh:nudsHoard" mode="cidoc"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="nuds:nuds|nh:nudsHoard" mode="pelagios">
		<xsl:variable name="id" select="descendant::*[local-name()='nudsid']"/>

		<oac:Annotation rdf:about="{$url}pelagios.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="descendant::*[local-name()='descMeta']/*[local-name()='title']"/>
			</dcterms:title>
			<xsl:for-each select="distinct-values(exsl:node-set($rdf)//skos:related[contains(@rdf:resource, 'pleiades')]/@rdf:resource)">
				<oac:hasBody rdf:resource="{.}#this"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$url}id/{$id}"/>
		</oac:Annotation>
	</xsl:template>
	
	<xsl:template match="nuds:nuds|nh:nudsHoard" mode="ctype">
		<xsl:variable name="id" select="descendant::*[local-name()='nudsid']"/>
		
		<oac:Annotation rdf:about="{$url}ctype.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="descendant::*[local-name()='descMeta']/*[local-name()='title']"/>
			</dcterms:title>
			<xsl:for-each select="descendant::nuds:typeDesc/@xlink:href|descendant::nuds:undertypeDesc/@xlink:href">
				<oac:hasBody rdf:resource="{.}"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$url}id/{$id}"/>
		</oac:Annotation>
	</xsl:template>

	<xsl:template match="nuds:nuds|nh:nudsHoard" mode="cidoc">
		<xsl:variable name="id" select="descendant::*[local-name()='nudsid']"/>

		<xsl:text>(not yet developed)</xsl:text>
	</xsl:template>

	<!-- ************** SOLR-TO-XML **************** -->
	<xsl:template name="atom">
		<xsl:param name="section"/>
		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="$section='api'">
					<xsl:text>apis/search</xsl:text>
				</xsl:when>
				<xsl:when test="$section='feed'">
					<xsl:text>feed/</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number($numFound - ($numFound mod 100))"/>
		<xsl:variable name="next" select="$start_var + 100"/>
		
		<!-- create sort parameter if there is string($sort) -->
		<xsl:variable name="sortParam">
			<xsl:if test="string($sort)">
				<xsl:text>&amp;sort=</xsl:text>
				<xsl:value-of select="$sort"/>
			</xsl:if>
		</xsl:variable>

		<feed xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml/" xmlns:gx="http://www.google.com/kml/ext/2.2"
			xmlns="http://www.w3.org/2005/Atom">
			<title>
				<xsl:value-of select="/content/config/title"/>
			</title>
			<id>
				<xsl:value-of select="$url"/>
			</id>
			<link rel="self" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$start_var}{$sortParam}"/>
			<link rel="alternative" type="text/html" href="{$url}results?q={$q}&amp;start={$start_var}{$sortParam}"/>
			<xsl:if test="$next != $last">
				<link rel="next" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$next}{$sortParam}"/>
			</xsl:if>
			<link rel="last" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$last}{$sortParam}"/>
			<link rel="search" type="application/opensearchdescription+xml" href="{$url}opensearch.xml"/>
			<author>
				<name>
					<xsl:value-of select="//config/templates/publisher"/>
				</name>
			</author>
			<!-- opensearch results -->
			<opensearch:totalResults>
				<xsl:value-of select="$numFound"/>
			</opensearch:totalResults>
			<opensearch:startIndex>
				<xsl:value-of select="$start_var"/>
			</opensearch:startIndex>
			<opensearch:itemsPerPage>
				<xsl:value-of select="$rows"/>
			</opensearch:itemsPerPage>
			<opensearch:Query role="request" searchTerms="{$q}" startPage="{$start_var}"/>

			<xsl:apply-templates select="descendant::doc" mode="atom"/>
		</feed>
	</xsl:template>

	<xsl:template name="rss">
		<xsl:param name="section"/>
		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="$section='api'">
					<xsl:text>apis/search</xsl:text>
				</xsl:when>
				<xsl:when test="$section='feed'">
					<xsl:text>feed/</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number($numFound - ($numFound mod 100))"/>
		<xsl:variable name="next" select="$start_var + 100"/>
		
		<!-- create sort parameter if there is string($sort) -->
		<xsl:variable name="sortParam">
			<xsl:if test="string($sort)">
				<xsl:text>&amp;sort=</xsl:text>
				<xsl:value-of select="$sort"/>
			</xsl:if>
		</xsl:variable>

		<rss version="2.0" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
			<channel>
				<title>
					<xsl:value-of select="/content/config/title"/>
				</title>
				<description>Numishare Collection</description>				
				<link>
					<xsl:value-of select="$url"/>
				</link>
				<xsl:if test="string(/content/config/template/copyrightHolder) or string(/content/config/template/license)">
					<copyright>
						<xsl:if test="string(/content/config/template/copyrightHolder)">Copyright: <xsl:value-of select="/content/config/template/copyrightHolder"/></xsl:if>
						<xsl:if test="string(/content/config/template/copyrightHolder) and string(/content/config/template/license)"><xsl:text>, </xsl:text></xsl:if>
						<xsl:if test="string(/content/config/template/license)">License: <xsl:value-of select="/content/config/template/license"/></xsl:if>
					</copyright>
				</xsl:if>
				<atom:link rel="self" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$start_var}{$sortParam}"/>
				<atom:link rel="alternative" type="text/html" href="{$url}results?q={$q}&amp;start={$start_var}{$sortParam}"/>
				<xsl:if test="$next != $last">
					<atom:link rel="next" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$next}{$sortParam}"/>
				</xsl:if>
				<atom:link rel="last" type="application/atom+xml" href="{$url}{$path}?q={$q}&amp;start={$last}{$sortParam}"/>
				<atom:link rel="search" type="application/opensearchdescription+xml" href="{$url}opensearch.xml"/>
				<!-- opensearch results -->
				<opensearch:totalResults>
					<xsl:value-of select="$numFound"/>
				</opensearch:totalResults>
				<opensearch:startIndex>
					<xsl:value-of select="$start_var"/>
				</opensearch:startIndex>
				<opensearch:itemsPerPage>
					<xsl:value-of select="$rows"/>
				</opensearch:itemsPerPage>
				<opensearch:Query role="request" searchTerms="{$q}" startPage="{$start_var}"/>

				<xsl:apply-templates select="descendant::doc" mode="rss"/>
			</channel>
		</rss>
	</xsl:template>

	<xsl:template match="doc" mode="atom">
		<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gml="http://www.opengis.net/gml/" xmlns:georss="http://www.georss.org/georss" xmlns:gx="http://www.google.com/kml/ext/2.2">
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name='title_display'])">
						<xsl:value-of select="str[@name='title_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name='id']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link href="{$url}id/{str[@name='id']}"/>
			<id>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>

			<link rel="alternate xml" type="text/xml" href="{$url}id/{str[@name='id']}.xml"/>
			<link rel="alternate rdf" type="application/rdf+xml" href="{$url}id/{str[@name='id']}.rdf"/>

			<!-- treat hoard and non-hoard documents differently -->
			<xsl:choose>
				<xsl:when test="str[@name='recordType'] = 'hoard'">
					<xsl:if test="arr[@name='findspot_geo']/str">
						<link rel="alternate kml" type="application/vnd.google-earth.kml+xml" href="{$url}id/{str[@name='id']}.kml"/>
					</xsl:if>
					
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name='recordType']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="str[@name='mint_geo']">
						<link rel="alternate kml" type="application/vnd.google-earth.kml+xml" href="{$url}id/{str[@name='id']}.kml"/>
					</xsl:if>
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name='recordType']"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</entry>
	</xsl:template>

	<xsl:template match="doc" mode="rss">
		<item>
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name='title_display'])">
						<xsl:value-of select="str[@name='title_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name='id']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link>
				<xsl:value-of select="concat($url, 'id/', str[@name='id'])"/>
			</link>
			<pubDate>
				<xsl:value-of select="date[@name='timestamp']"/>
			</pubDate>
			<xsl:choose>
				<xsl:when test="str[@name='recordType'] = 'hoard'">
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name='recordType']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name='recordType']"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</item>
	</xsl:template>
	
	<xsl:template name="geotemp">
		<xsl:param name="recordType"/>
		
		<xsl:choose>
			<xsl:when test="str[@name='recordType'] = 'hoard'">
				<xsl:if test="string(arr[@name='findspot_geo']/str)">
					<georss:where>
						<xsl:variable name="tokenized_georef" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')"/>
						<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>
						<xsl:variable name="lon" select="substring-before($coordinates, ',')"/>
						<xsl:variable name="lat" select="substring-after($coordinates, ',')"/>
						<gml:Point>
							<gml:pos>
								<xsl:value-of select="concat($lat, ' ', $lon)"/>
							</gml:pos>
						</gml:Point>
					</georss:where>
				</xsl:if>
				<xsl:if test="number(int[@name='tpq_num']) and number(int[@name='taq_num'])">
					<gx:TimeSpan>
						<gx:begin>
							<xsl:value-of select="int[@name='tpq_num']"/>
						</gx:begin>
						<gx:end>
							<xsl:value-of select="int[@name='taq_num']"/>
						</gx:end>
					</gx:TimeSpan>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(arr[@name='mint_geo']/str) &gt; 0">
					<georss:where>
						<xsl:for-each select="arr[@name='mint_geo']/str">
							<xsl:variable name="tokenized_georef" select="tokenize(., '\|')"/>
							<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>
							<xsl:variable name="lon" select="substring-before($coordinates, ',')"/>
							<xsl:variable name="lat" select="substring-after($coordinates, ',')"/>
							<gml:Point>
								<gml:pos>
									<xsl:value-of select="concat($lat, ' ', $lon)"/>
								</gml:pos>
							</gml:Point>
						</xsl:for-each>
					</georss:where>
				</xsl:if>
				<xsl:if test="count(arr[@name='year_num']/int) &gt; 1">
					<gx:TimeSpan>
						<begin>
							<xsl:value-of select="arr[@name='year_num']/int[1]"/>
						</begin>
						<end>
							<xsl:value-of select="arr[@name='year_num']/int[2]"/>
						</end>
					</gx:TimeSpan>
				</xsl:if>
				<xsl:if test="count(arr[@name='year_num']/int) = 1">
					<gx:TimeStamp>
						<when>
							<xsl:value-of select="arr[@name='year_num']/int"/>
						</when>
					</gx:TimeStamp>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- PELAGIOS RDF -->
	<xsl:template match="doc" mode="pelagios">
		<xsl:variable name="id" select="str[@name='id']"/>
		
		<oac:Annotation rdf:about="{$url}pelagios.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="str[@name='title_display']"/>
			</dcterms:title>
			<xsl:for-each select="arr[@name='pleiades_uri']/str">
				<oac:hasBody rdf:resource="{.}#this"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$url}id/{$id}"/>
		</oac:Annotation>
	</xsl:template>
	
	<!-- CTYPE RDF -->
	<xsl:template match="doc" mode="ctype">
		<xsl:variable name="id" select="str[@name='id']"/>
		<xsl:variable name="recordType" select="str[@name='recordType']"/>
		
		<oac:Annotation rdf:about="{$url}ctype.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="str[@name='title_display']"/>
			</dcterms:title>
			<dcterms:identifier>
				<xsl:value-of select="$id"/>
			</dcterms:identifier>
			<dcterms:publisher>
				<xsl:value-of select="str[@name='publisher_display']"/>
			</dcterms:publisher>
			<nm:numismatic_term rdf:resource="http://nomisma.org/id/{if($recordType='coin') then 'coin' else 'hoard'}"/>
			<!-- measurements for physical coins -->
			<xsl:if test="int[@name='axis_num']">
				<nm:axis rdf:datatype="xs:integer">
					<xsl:value-of select="int[@name='axis_num']"/>
				</nm:axis>
			</xsl:if>
			<xsl:if test="float[@name='diameter_num']">
				<nm:diameter rdf:datatype="xs:decimal">
					<xsl:value-of select="float[@name='diameter_num']"/>
				</nm:diameter>
			</xsl:if>
			<xsl:if test="float[@name='weight_num']">
				<nm:weight rdf:datatype="xs:decimal">
					<xsl:value-of select="float[@name='weight_num']"/>
				</nm:weight>
			</xsl:if>
			<!-- findspot information -->
			<xsl:if test="int[@name='taq_num']">
				<nm:approximateburialdate rdf:datatype="xs:gYear">
					<xsl:value-of select="format-number(int[@name='taq_num'], '0000')"/>					
				</nm:approximateburialdate>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="string(arr[@name='findspot_uri']/str)">
					<nm:findspot rdf:resource="{arr[@name='findspot_uri']/str}"/>
				</xsl:when>
				<xsl:when test="string(arr[@name='findspot_geo']/str[1])">
					<nm:findspot>
						<xsl:value-of select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[last()]"/>
					</nm:findspot>
				</xsl:when>
			</xsl:choose>
			<!-- images -->
			<xsl:if test="string(str[@name='thumbnail_obv'])">
				<nm:obverseThumbnail rdf:resource="str[@name='thumbnail_obv']"/>
			</xsl:if>
			<xsl:if test="string(str[@name='reference_obv'])">
				<nm:obverseReference rdf:resource="str[@name='reference_obv']"/>
			</xsl:if>
			<xsl:if test="string(str[@name='thumbnail_rev'])">
				<nm:reverseThumbnail rdf:resource="str[@name='thumbnail_rev']"/>
			</xsl:if>
			<xsl:if test="string(str[@name='reference_rev'])">
				<nm:reverseReference rdf:resource="str[@name='reference_rev']"/>
			</xsl:if>
			<xsl:for-each select="arr[@name='coinType_uri']/str">
				<oac:hasBody rdf:resource="{.}"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$url}id/{$id}"/>
		</oac:Annotation>
	</xsl:template>

</xsl:stylesheet>
