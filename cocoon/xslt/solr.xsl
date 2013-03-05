<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Modified: April 2012
	Function: This stylesheet reads the incoming object model (nuds or nudsHoard)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:nm="http://nomisma.org/id/"
	xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:cinclude="http://apache.org/cocoon/include/1.0"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="functions.xsl"/>
	<xsl:include href="display/nuds/solr.xsl"/>
	<xsl:include href="display/nudsHoard/solr.xsl"/>
	<xsl:include href="display/shared-solr.xsl"/>

	<xsl:param name="collection-name"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="publisher" select="/content/config/template/publisher"/>

	<xsl:variable name="nudsGroup">
		<nudsGroup>
			<!-- get nomisma NUDS documents with get-nuds API -->
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="string-length($id-param) &gt; 0">
				<xsl:for-each select="document(concat('http://nomisma.org/get-nuds?id=', encode-for-uri($id-param)))//nuds:nuds">
					<object xlink:href="http://nomisma.org/id/{nuds:nudsHeader/nuds:nudsid}">
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>

			<!-- incorporate other typeDescs which do not point to nomisma.org -->
			<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href) and not(contains(@xlink:href, 'nomisma.org'))]/@xlink:href)">
				<xsl:variable name="href" select="."/>
				<xsl:if test="boolean(document(concat($href, '.xml')))">
					<object xlink:href="{$href}">
						<xsl:copy-of select="document(concat($href, '.xml'))/nuds:nuds"/>
					</object>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
				<object>
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf">
		<rdf:RDF>
			<xsl:variable name="count"
				select="count(distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | exsl:node-set($nudsGroup)/descendant::*[not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href))"/>

			<xsl:call-template name="get-ids">
				<xsl:with-param name="start">1</xsl:with-param>
				<xsl:with-param name="end">100</xsl:with-param>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</rdf:RDF>
	</xsl:variable>

	<!-- accumulate unique geonames IDs -->
	<xsl:variable name="geonames">
		<places>
			<xsl:for-each select="distinct-values(descendant::*[local-name()='geogname'][contains(@xlink:href, 'geonames.org')]/@xlink:href|exsl:node-set($rdf)/descendant::*[contains(@rdf:resource, 'geonames.org')]/@rdf:resource)">
				<xsl:variable name="geonameId" select="substring-before(substring-after(., 'geonames.org/'), '/')"/>
				<xsl:variable name="geonames_data" as="element()*">
					<results>
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					</results>
				</xsl:variable>
				<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
				
				<!-- create facetRegion hierarchy -->
				<xsl:variable name="hierarchy">
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
				
				<place id="{.}" hierarchy="{$hierarchy}">
					<xsl:value-of select="$coordinates"/>
				</place>
			</xsl:for-each>
		</places>
	</xsl:variable>

	<xsl:template name="get-ids">
		<xsl:param name="start"/>
		<xsl:param name="end"/>
		<xsl:param name="count"/>

		<xsl:variable name="id-param">
			<xsl:for-each
				select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href, 'nomisma.org')]/@xlink:href | exsl:node-set($nudsGroup)/descendant::*[not(local-name()='typeDesc') and not(local-name()='object')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
				<xsl:if test="position() &gt;= $start and position() &lt;= $end">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=$end)">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="rdf_url" select="concat('http://www.w3.org/2012/pyRdfa/extract?format=xml&amp;uri=', encode-for-uri(concat('http://nomisma.org/get-ids?id=', $id-param)))"/>
		<xsl:copy-of select="document($rdf_url)/descendant::*[string(@rdf:about) and not(local-name()='Description')]"/>

		<xsl:if test="$end &lt; $count">
			<xsl:call-template name="get-ids">
				<xsl:with-param name="start" select="$start + $end"/>
				<xsl:with-param name="end" select="($start + 1) * 100"/>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<add>
			<xsl:choose>
				<xsl:when test="count(descendant::nuds:nuds) &gt; 0">
					<xsl:call-template name="nuds"/>
				</xsl:when>
				<xsl:when test="count(descendant::nh:nudsHoard) &gt; 0">
					<xsl:call-template name="nudsHoard"/>
				</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</add>
	</xsl:template>
</xsl:stylesheet>
