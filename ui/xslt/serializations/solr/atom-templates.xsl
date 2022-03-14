<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: March 2022
	Function: Generate Atom/RSS feed for Solr results, using URI space for union catalogs, if necessary -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl numishare nm"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nm="http://nomisma.org/id/" xmlns:georss="http://www.georss.org/georss"
	xmlns:relevance="http://a9.com/-/opensearch/extensions/relevance/1.0/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:gx="http://www.google.com/kml/ext/2.2"
	xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">
	<!-- ************** SOLR-TO-XML **************** -->
	<xsl:template name="atom">
		<xsl:param name="section"/>
		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="$section = 'api'">
					<xsl:text>apis/search</xsl:text>
				</xsl:when>
				<xsl:when test="$section = 'feed'">
					<xsl:text>feed/</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name = 'response']/@numFound)"/>
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
		
		<feed xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:georss="http://www.georss.org/georss"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns="http://www.w3.org/2005/Atom"
			xmlns:relevance="http://a9.com/-/opensearch/extensions/relevance/1.0/">
			<title>
				<xsl:value-of select="/content/config/title"/>
			</title>
			<xsl:if test="//config/templates/agencyName">
				<author>
					<name>
						<xsl:value-of select="//config/templates/agencyName"/>
					</name>
				</author>
			</xsl:if>
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
				<xsl:when test="$section = 'api'">
					<xsl:text>apis/search</xsl:text>
				</xsl:when>
				<xsl:when test="$section = 'feed'">
					<xsl:text>feed/</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name = 'response']/@numFound)"/>
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
		<xsl:variable name="object-path">
			<xsl:choose>
				<xsl:when test="//config/collection_type = 'object' and string(//config/uri_space)">
					<xsl:value-of select="//config/uri_space"/>
				</xsl:when>
				<xsl:when test="//config/union_type_catalog/@enabled = true()">
					<xsl:value-of select="str[@name = 'uri_space']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<entry xmlns="http://www.w3.org/2005/Atom" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:georss="http://www.georss.org/georss"
			xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:relevance="http://a9.com/-/opensearch/extensions/relevance/1.0/">
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name = 'title_display'])">
						<xsl:value-of select="str[@name = 'title_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name = 'recordId']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>

			<link href="{$object-path}{str[@name='recordId']}"/>

			<id>
				<xsl:value-of select="str[@name = 'recordId']"/>
			</id>
			<relevance:score>
				<xsl:value-of select="float[@name = 'score']"/>
			</relevance:score>
			<updated>
				<xsl:value-of select="date[@name = 'timestamp']"/>
			</updated>
			<link rel="alternate" type="application/xml" href="{$object-path}{str[@name='recordId']}.xml"/>
			<link rel="alternate" type="application/rdf+xml" href="{$object-path}{str[@name='recordId']}.rdf"/>
			<link rel="alternate" type="application/ld+json" href="{$object-path}{str[@name='recordId']}.jsonld"/>
			<link rel="alternate" type="text/turtle" href="{$object-path}{str[@name='recordId']}.ttl"/>
			<!-- treat hoard and non-hoard documents differently -->
			<xsl:choose>
				<xsl:when test="str[@name = 'recordType'] = 'hoard'">
					<xsl:if test="str[@name = 'findspot_geo']">
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{$object-path}{str[@name='recordId']}.kml"/>
					</xsl:if>
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name = 'recordType']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="str[@name = 'mint_geo']">
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{$object-path}{str[@name='recordId']}.kml"/>
					</xsl:if>
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name = 'recordType']"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</entry>
	</xsl:template>
	
	<xsl:template match="doc" mode="rss">
		<xsl:variable name="object-path">
			<xsl:choose>
				<xsl:when test="//config/collection_type = 'object' and string(//config/uri_space)">
					<xsl:value-of select="//config/uri_space"/>
				</xsl:when>
				<xsl:when test="//config/union_type_catalog/@enabled = true()">
					<xsl:value-of select="str[@name = 'uri_space']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<item>
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name = 'title_display'])">
						<xsl:value-of select="str[@name = 'title_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name = 'recordId']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link>
				<xsl:value-of select="concat($object-path, str[@name = 'recordId'])"/>
			</link>
			<pubDate>
				<xsl:value-of select="date[@name = 'timestamp']"/>
			</pubDate>
			<xsl:choose>
				<xsl:when test="str[@name = 'recordType'] = 'hoard'">
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name = 'recordType']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name = 'recordType']"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</item>
	</xsl:template>

	<xsl:template name="geotemp">
		<xsl:param name="recordType"/>
		<xsl:choose>
			<xsl:when test="str[@name = 'recordType'] = 'hoard'">
				<xsl:if test="string(str[@name = 'findspot_geo'])">
					<georss:where>
						<xsl:variable name="tokenized_georef" select="tokenize(str[@name = 'findspot_geo'], '\|')"/>
						<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>
						<xsl:variable name="lon" select="substring-before($coordinates, ',')"/>
						<xsl:variable name="lat" select="substring-after($coordinates, ',')"/>
						<geo:Point>
							<geo:pos>
								<xsl:value-of select="concat($lat, ' ', $lon)"/>
							</geo:pos>
						</geo:Point>
					</georss:where>
				</xsl:if>
				<xsl:if test="number(int[@name = 'tpq_num']) and number(int[@name = 'taq_num'])">
					<gx:TimeSpan>
						<gx:begin>
							<xsl:value-of select="int[@name = 'tpq_num']"/>
						</gx:begin>
						<gx:end>
							<xsl:value-of select="int[@name = 'taq_num']"/>
						</gx:end>
					</gx:TimeSpan>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(arr[@name = 'mint_geo']/str) &gt; 0">
					<georss:where>
						<xsl:for-each select="arr[@name = 'mint_geo']/str">
							<xsl:variable name="tokenized_georef" select="tokenize(., '\|')"/>
							<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>
							<xsl:variable name="lon" select="substring-before($coordinates, ',')"/>
							<xsl:variable name="lat" select="substring-after($coordinates, ',')"/>
							<geo:Point>
								<geo:pos>
									<xsl:value-of select="concat($lat, ' ', $lon)"/>
								</geo:pos>
							</geo:Point>
						</xsl:for-each>
					</georss:where>
				</xsl:if>
				<xsl:if test="count(arr[@name = 'year_num']/int) &gt; 1">
					<gx:TimeSpan>
						<begin>
							<xsl:value-of select="arr[@name = 'year_num']/int[1]"/>
						</begin>
						<end>
							<xsl:value-of select="arr[@name = 'year_num']/int[2]"/>
						</end>
					</gx:TimeSpan>
				</xsl:if>
				<xsl:if test="count(arr[@name = 'year_num']/int) = 1">
					<gx:TimeStamp>
						<when>
							<xsl:value-of select="arr[@name = 'year_num']/int"/>
						</when>
					</gx:TimeStamp>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
