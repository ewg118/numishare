<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gml="http://www.opengis.net/gml"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:variable name="id" select="descendant::*:recordId"/>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href|descendant::nuds:reference[@xlink:arcrole='nmo:hasTypeSeriesItem'][string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:if test="contains(., '/id/')">
								<xsl:attribute name="type_series" select="substring-before(., 'id/')"/>
							</xsl:if>
							
							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>
			
			<xsl:for-each select="distinct-values($type_list//type_series_item/@type_series)">
				<xsl:variable name="type_series_uri" select="."/>
				
				<xsl:variable name="id-param">
					<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position() = last())">
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
			
			<!-- include individual REST calls for URIs not in a recognized, Numishare based id/ namespace -->
			<xsl:for-each select="$type_list//type_series_item[not(@type_series)]">
				<xsl:variable name="uri" select="."/>
				
				<xsl:call-template name="numishare:getNudsDocument">
					<xsl:with-param name="uri" select="$uri"/>
				</xsl:call-template>
			</xsl:for-each>
			
			<!-- get typeDesc -->
			<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
				<object>
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
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
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:variable name="model" as="element()*">
			<_array>
				<xsl:apply-templates
					select="descendant::nh:geogname[@xlink:role = 'findspot'][string(@xlink:href)] | $nudsGroup/descendant::nuds:geogname[@xlink:role = 'mint'][string(@xlink:href)]"
				/>
			</_array>
		</xsl:variable>
		
		<xsl:apply-templates select="$model"/>
	</xsl:template>
	
	<xsl:template match="*:geogname">
		<xsl:call-template name="generateFeature">
			<xsl:with-param name="uri" select="@xlink:href"/>
			<xsl:with-param name="type">
				<xsl:choose>
					<xsl:when test="@xlink:role = 'mint'">mint</xsl:when>
					<xsl:when test="@xlink:role = 'findspot'">findspot</xsl:when>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="generateFeature">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>

		<xsl:variable name="geonames_data" as="element()*">
			<xsl:choose>
				<xsl:when test="contains($uri, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($uri, '/')[4]"/>
					<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
				</xsl:when>
				<xsl:otherwise>
					<empty/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="name">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>				
				<xsl:when test="local-name() = 'findspotDesc'">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
				</xsl:when>
				<xsl:when test="local-name() = 'findspot'">
					<xsl:value-of select="nuds:geogname"/>
				</xsl:when>
				<xsl:when test="@xlink:role = 'mint'">
					<xsl:value-of select="numishare:getNomismaLabel($rdf/*[@rdf:about = $uri], $lang)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="coordinates">
			<xsl:choose>
				<!-- evaluate the URI and extract coordinates -->
				<xsl:when test="string($uri)">
					<xsl:choose>
						<xsl:when test="contains($uri, 'geonames')">
							<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
						</xsl:when>
						<xsl:when test="contains($uri, 'nomisma')">
							<xsl:choose>
								<!-- when there is a geo:SpatialThing associated with the mint that contains a lat and long: -->
								<xsl:when test="$rdf//*[@rdf:about = concat($uri, '#this')]/geo:long and $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat">
									<xsl:value-of select="concat($rdf//*[@rdf:about = concat($uri, '#this')]/geo:long, ',', $rdf//*[@rdf:about = concat($uri, '#this')]/geo:lat)"/>
								</xsl:when>
								<xsl:when test="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot[@rdf:resource]">
									<xsl:variable name="findspotURI" select="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot/@rdf:resource"/>
									<xsl:value-of select="concat($rdf//*[@rdf:about = $findspotURI]/geo:long, ',', $rdf//*[@rdf:about = $findspotURI]/geo:lat)"/>
								</xsl:when>
								<!-- if the URI contains a skos:related linking to an uncertain mint attribution -->
								<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:related">
									<xsl:variable name="uncertainMint" as="node()*">
										<xsl:copy-of select="document(concat($rdf//*[@rdf:about = $uri]/skos:related/rdf:Description/rdf:value/@rdf:resource, '.rdf'))"/>
									</xsl:variable>

									<xsl:if test="$uncertainMint//geo:long and $uncertainMint//geo:lat">
										<xsl:value-of select="concat($uncertainMint//geo:long, ',', $uncertainMint//geo:lat)"/>
									</xsl:if>
								</xsl:when>
								<!-- if the mint does not have coordinates, but does have skos:broader, exectue the region hierarchy API call to look for parent mint/region coordinates -->
								<xsl:when test="$rdf//*[@rdf:about = $uri]/skos:broader">
									<xsl:variable name="regions" as="node()*">
										<xsl:copy-of
											select="document(concat('http://nomisma.org/apis/regionHierarchy?identifiers=', encode-for-uri(substring-after($uri, 'http://nomisma.org/id/'))))"
										/>
									</xsl:variable>

									<xsl:if test="$regions//mint[1][@lat and @long]">
										<xsl:value-of select="concat($regions//mint[1]/@long, ',', $regions//mint[1]/@lat)"/>
									</xsl:if>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains($uri, 'coinhoards.org')">
							<xsl:variable name="findspotUri" select="$rdf//*[@rdf:about = $uri]/nmo:hasFindspot/@rdf:resource"/>

							<xsl:if test="string-length($findspotUri) &gt; 0">
								<xsl:value-of select="concat($rdf//*[@rdf:about = $findspotUri]/geo:long, ',', $rdf//*[@rdf:about = $findspotUri]/geo:lat)"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<!-- otherwise use the gml:Point stored within NUDS -->
				<xsl:when test="gml:Point">
					<xsl:variable name="coords" select="tokenize(gml:Point/gml:coordinates, ',')"/>
					<xsl:value-of select="concat(normalize-space($coords[2]), ',', normalize-space($coords[1]))"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($coordinates) &gt; 0">
			<_object>
				<type>Feature</type>
				<geometry>
					<_object>
						<type>Point</type>
						<coordinates>
							<_array>
								<xsl:value-of select="$coordinates"/>
							</_array>
						</coordinates>
					</_object>
				</geometry>
				<properties>
					<_object>
						<name>
							<xsl:value-of select="$name"/>
						</name>
						<xsl:if test="string($uri)">
							<uri>
								<xsl:value-of select="$uri"/>
							</uri>
						</xsl:if>
						<type>
							<xsl:value-of select="$type"/>
						</type>
					</_object>
				</properties>
			</_object>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
