<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<xsl:variable name="id" select="descendant::*:recordId"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_series" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
						<type_series>
							<xsl:value-of select="."/>
						</type_series>
					</xsl:for-each>
				</list>
			</xsl:variable>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>

			<xsl:for-each select="$type_series//type_series">
				<xsl:variable name="type_series_uri" select="."/>

				<xsl:variable name="id-param">
					<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position()=last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
						<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
							<xsl:copy-of select="."/>
						</object>
					</xsl:for-each>
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
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href,
					'nomisma.org')]/@xlink:href|$nudsGroup/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
			
			<xsl:if test="descendant::nuds:findspotDesc[contains(@xlink:href, 'coinhoards.org')]">
				<xsl:copy-of select="document(concat(descendant::nuds:findspotDesc/@xlink:href, '.rdf'))/rdf:RDF/*"/>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
				<xsl:apply-templates select="/content/nuds:nuds"/>
			</xsl:when>
			<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
				<xsl:apply-templates select="/content/nh:nudsHoard"/>
			</xsl:when>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template match="nuds:nuds">
		<xsl:choose>			
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]|descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]) &gt; 1">
				<xsl:text>[</xsl:text>
			</xsl:when>
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]|descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]) = 0">
				<xsl:text>{</xsl:text>
			</xsl:when>
		</xsl:choose>
		
		
		<!-- create mint points -->
		<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|$nudsGroup/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]|descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
			<xsl:call-template name="generateFeature">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="type">
					<xsl:choose>
						<xsl:when test="@xlink:role='mint'">mint</xsl:when>
						<xsl:when test="@xlink:role='findspot' or self::nuds:findspotDesc">findspot</xsl:when>
						<xsl:when test="self::nuds:subject">subject</xsl:when>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:choose>			
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]|descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]) &gt; 1">
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]|descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]) = 0">
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="nh:nudsHoard">
		<xsl:choose>			
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]) &gt; 1">
				<xsl:text>[</xsl:text>
			</xsl:when>
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]) = 0">
				<xsl:text>{</xsl:text>
			</xsl:when>
		</xsl:choose>
		
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]|$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="generateFeature">
				<xsl:with-param name="uri" select="@xlink:href"/>
				<xsl:with-param name="type">
					<xsl:choose>
						<xsl:when test="@xlink:role='mint'">mapped</xsl:when>
						<xsl:when test="@xlink:role='findspot'">findspot</xsl:when>
					</xsl:choose>
				</xsl:with-param>				
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:choose>			
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]) &gt; 1">
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="count($nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]|descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]) = 0">
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="generateFeature">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>
		
		<xsl:variable name="name">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>
				<xsl:when test="$type='mapped'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:when test="local-name()='findspotDesc'">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$uri], $lang)"/>
				</xsl:when>
				<xsl:when test="@xlink:role='mint'">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about=$uri], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="coordinates">
			<xsl:choose>
				<xsl:when test="contains($uri, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($uri, '/')[4]"/>
					<xsl:variable name="geonames_data" as="element()*">
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
					</xsl:variable>
					
					<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>				
				</xsl:when>
				<xsl:when test="contains($uri, 'nomisma')">
					<xsl:variable name="coordinates">
						<xsl:if test="$rdf//*[@rdf:about=concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about=concat($uri, '#this')]/geo:lat">true</xsl:if>
					</xsl:variable>
					<xsl:if test="$coordinates='true'">
						<xsl:value-of select="concat($rdf//*[@rdf:about=concat($uri, '#this')]/geo:long, ',', $rdf//*[@rdf:about=concat($uri, '#this')]/geo:lat)"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="contains($uri, 'coinhoards.org')">
					<xsl:variable name="findspotUri" select="$rdf//*[@rdf:about=$uri]/nmo:hasFindspot/@rdf:resource"/>
					
					<xsl:if test="string-length($findspotUri) &gt; 0">
						<xsl:value-of select="concat($rdf//*[@rdf:about=$findspotUri]/geo:long, ',', $rdf//*[@rdf:about=$findspotUri]/geo:lat)"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>		
		
		<xsl:if test="string-length($coordinates) &gt; 0">
			<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
			<xsl:value-of select="$coordinates"/>
			<xsl:text>]},"properties": {"name": "</xsl:text>
			<xsl:value-of select="$name"/>
			<xsl:text>", "uri": "</xsl:text>
			<xsl:value-of select="$uri"/>
			<xsl:text>","type": "</xsl:text>
			<xsl:value-of select="$type"/>
			<xsl:text>"</xsl:text>	
			<xsl:text>}}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>	
		</xsl:if>		
	</xsl:template>

</xsl:stylesheet>
