<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:georss="http://www.georss.org/georss" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">


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

		<feed xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns="http://www.w3.org/2005/Atom">
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
					<xsl:value-of select="//config/templates/agencyName"/>
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
						<xsl:if test="string(/content/config/template/copyrightHolder) and string(/content/config/template/license)">
							<xsl:text>, </xsl:text>
						</xsl:if>
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
		<entry xmlns="http://www.w3.org/2005/Atom" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:georss="http://www.georss.org/georss" xmlns:gx="http://www.google.com/kml/ext/2.2">
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name='title_display'])">
						<xsl:value-of select="str[@name='title_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name='recordId']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link href="{$url}id/{str[@name='recordId']}"/>
			<id>
				<xsl:value-of select="str[@name='recordId']"/>
			</id>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>

			<link rel="alternate xml" type="text/xml" href="{$url}id/{str[@name='recordId']}.xml"/>
			<link rel="alternate rdf" type="application/rdf+xml" href="{$url}id/{str[@name='recordId']}.rdf"/>

			<!-- treat hoard and non-hoard documents differently -->
			<xsl:choose>
				<xsl:when test="str[@name='recordType'] = 'hoard'">
					<xsl:if test="str[@name='findspot_geo']">
						<link rel="alternate kml" type="application/vnd.google-earth.kml+xml" href="{$url}id/{str[@name='recordId']}.kml"/>
					</xsl:if>

					<xsl:call-template name="geotemp">
						<xsl:with-param name="recordType" select="str[@name='recordType']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="str[@name='mint_geo']">
						<link rel="alternate kml" type="application/vnd.google-earth.kml+xml" href="{$url}id/{str[@name='recordId']}.kml"/>
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
						<xsl:value-of select="str[@name='recordId']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link>
				<xsl:value-of select="concat($url, 'id/', str[@name='recordId'])"/>
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
				<xsl:if test="string(str[@name='findspot_geo'])">
					<georss:where>
						<xsl:variable name="tokenized_georef" select="tokenize(str[@name='findspot_geo'], '\|')"/>
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
							<geo:Point>
								<geo:pos>
									<xsl:value-of select="concat($lat, ' ', $lon)"/>
								</geo:pos>
							</geo:Point>
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
</xsl:stylesheet>