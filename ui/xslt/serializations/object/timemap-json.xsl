<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<!-- URL parameters -->
	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'apis/'))"/>
	
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

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
		<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="root"/>
	</xsl:template>
	
	<xsl:template match="*" mode="root">
		<xsl:text> [ </xsl:text>
		<xsl:choose>
			<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
				<xsl:apply-templates select="/content/nuds:nuds"/>
			</xsl:when>
			<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
				<xsl:apply-templates select="/content/nh:nudsHoard"/>
			</xsl:when>
		</xsl:choose>
		<xsl:text> ] </xsl:text>
	</xsl:template>
	
	<xsl:template match="nuds:nuds">
		<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:variable name="href" select="@xlink:href"/>
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="$href"/>
				<xsl:with-param name="type">object-mint</xsl:with-param>
				<xsl:with-param name="title" select="if (string($lang)) then numishare:getNomismaLabel($rdf/*[@rdf:about=$href], $lang) else ."/>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
			<xsl:variable name="href" select="@xlink:href"/>
			<xsl:if test="$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="$href"/>
				<xsl:with-param name="type">subject</xsl:with-param>
				<xsl:with-param name="title" select="."/>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- gather associated hoards from Nomisma is available -->
		<xsl:choose>
			<xsl:when test="string($sparql_endpoint)">
				<xsl:variable name="service" select="concat($request-uri, 'sparql?uri=', //config/uri_space, $id, '&amp;template=json')"/>
				<xsl:value-of select="document($service)/response"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]">
					<xsl:call-template name="getJsonPoint">
						<xsl:with-param name="href" select="@xlink:href"/>
						<xsl:with-param name="type">findspot</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="nh:nudsHoard">
		<!-- display map point for findspot -->
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">findspot</xsl:with-param>
				<xsl:with-param name="title" select="."/>
			</xsl:call-template>
			<xsl:if test="count(distinct-values($nudsGroup/descendant::nuds:geogname[@xlink:role='mint']/@xlink:href)) &gt; 0">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- display map points for mints only -->
		<xsl:for-each select="distinct-values($nudsGroup/descendant::nuds:geogname[@xlink:role='mint']/@xlink:href)">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="."/>
				<xsl:with-param name="type">mint</xsl:with-param>
				<xsl:with-param name="title">
					<xsl:variable name="href" select="."/>
					<xsl:choose>
						<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string($rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang])">
									<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang=$lang]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel[@xml:lang='en']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="count($nudsGroup//nuds:typeDesc) &gt; 0">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<!-- create timeline only events for associated coin types -->
		<xsl:for-each select="$nudsGroup/descendant::nuds:typeDesc">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href"/>
				<xsl:with-param name="type">coinType</xsl:with-param>
				<xsl:with-param name="title">
					<xsl:choose>
						<xsl:when test="parent::nuds:descMeta/nuds:title">
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="lang($lang, parent::nuds:descMeta/nuds:title)">
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang=$lang]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="lang('en', parent::nuds:descMeta/nuds:title)">
													<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang='en']"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="parent::nuds:descMeta/nuds:title[1]"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="lang('en', parent::nuds:descMeta/nuds:title)">
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[@xml:lang='en']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="parent::nuds:descMeta/nuds:title[1]"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="nuds:denomination">
									<xsl:value-of select="nuds:denomination"/>
								</xsl:when>
								<xsl:otherwise>[No Title]</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getJsonPoint">
		<xsl:param name="href"/>
		<xsl:param name="type"/>
		<xsl:param name="title"/>
		<!-- generate json values -->
		<xsl:variable name="coordinates">
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
					<xsl:variable name="geonames_data" as="element()*">
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
					</xsl:variable>
					<xsl:variable name="lat" select="$geonames_data//lat"/>
					<xsl:variable name="lon" select="$geonames_data//lng"/>
					<xsl:choose>
						<xsl:when test="string($lat) and string($lon)">
							<xsl:value-of select="$lat"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="$lon"/>
						</xsl:when>
						<xsl:otherwise>NULL</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coords">
						<xsl:if test="$rdf/*[@rdf:about=concat($href, '#this')]/geo:lat and $rdf/*[@rdf:about=concat($href, '#this')]/geo:long">
							<xsl:text>true</xsl:text>
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$coords = 'true'">
							<xsl:value-of select="concat($rdf/*[@rdf:about=concat($href, '#this')]/geo:lat, '|', $rdf/*[@rdf:about=concat($href, '#this')]/geo:long)"/>
						</xsl:when>
						<xsl:otherwise>NULL</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="$type='coinType'">
					<!-- get coordinates of mint, if applicable-->
					<xsl:choose>
						<xsl:when test="nuds:geographic/nuds:geogname[@xlink:role='mint'][@xlink:href]">
							<xsl:variable name="thisHref" select="nuds:geographic/nuds:geogname[@xlink:role='mint'][1]/@xlink:href"/>
							<xsl:variable name="coordinates">
								<xsl:choose>
									<xsl:when test="contains($thisHref, 'geonames')">
										<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
										<xsl:variable name="geonames_data" as="element()*">
											<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
										</xsl:variable>
										<xsl:variable name="lat" select="$geonames_data//lat"/>
										<xsl:variable name="lon" select="$geonames_data//lng"/>
										<xsl:choose>
											<xsl:when test="string($lat) and string($lon)">
												<xsl:value-of select="$lat"/>
												<xsl:text>|</xsl:text>
												<xsl:value-of select="$lon"/>
											</xsl:when>
											<xsl:otherwise>NULL</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="contains($thisHref, 'nomisma')">
										<xsl:variable name="coords">
											<xsl:if test="$rdf/*[@rdf:about=concat($href, '#this')]/geo:lat and $rdf/*[@rdf:about=concat($href, '#this')]/geo:long">
												<xsl:text>true</xsl:text>
											</xsl:if>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="$coords = 'true'">
												<xsl:value-of select="concat($rdf/*[@rdf:about=concat($href, '#this')]/geo:lat, '|', $rdf/*[@rdf:about=concat($href, '#this')]/geo:long)"/>
											</xsl:when>
											<xsl:otherwise>NULL</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<![CDATA[<table style='width:100%'><tr><td style='width:50%'>]]>
							<xsl:if test="$coordinates != 'NULL'">
								<![CDATA[<<img src='http://maps.google.com/maps/api/staticmap?size=120x120&zoom=4&markers=color:blue%7C]]><xsl:value-of select="replace($coordinates, '\|', ',')"/>
								<![CDATA[&sensor=false&maptype=terrain'/>]]>
							</xsl:if>
							<![CDATA[</td>]]>
							<!-- display date -->
							<![CDATA[<td style='width:50%'>]]>
							<xsl:choose>
								<xsl:when test="string($lang)">
									<xsl:choose>
										<xsl:when test="string($rdf/*[@rdf:about=$thisHref]/skos:prefLabel[@xml:lang=$lang])">
											<xsl:value-of select="$rdf/*[@rdf:about=$thisHref]/skos:prefLabel[@xml:lang=$lang]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$rdf/*[@rdf:about=$thisHref]/skos:prefLabel[@xml:lang='en']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="nuds:geographic/nuds:geogname[@xlink:role='mint'][@xlink:href][1]"/>
								</xsl:otherwise>
							</xsl:choose>
							<![CDATA[<br/>]]>
							<xsl:if test="nuds:date or nuds:dateRange">
								<xsl:choose>
									<xsl:when test="string(nuds:date)">
										<xsl:value-of select="nuds:date"/>
									</xsl:when>
									<xsl:when test="string(nuds:dateRange)">
										<xsl:value-of select="nuds:dateRange/nuds:fromDate"/>
										<xsl:text> - </xsl:text>
										<xsl:value-of select="nuds:dateRange/nuds:toDate"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<![CDATA[</td></tr></table>]]>
						</xsl:when>
						<xsl:otherwise>
							<!-- display date -->
							<xsl:if test="nuds:date or nuds:dateRange">
								<xsl:choose>
									<xsl:when test="string(nuds:date)">
										<xsl:value-of select="nuds:date"/>
									</xsl:when>
									<xsl:when test="string(nuds:dateRange)">
										<xsl:value-of select="nuds:dateRange/nuds:fromDate"/>
										<xsl:text> - </xsl:text>
										<xsl:value-of select="nuds:dateRange/nuds:toDate"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$type='mint' or $type='object-mint'">
					<![CDATA[<a href=']]><xsl:value-of select="$href"/><![CDATA['>]]><xsl:value-of select="$href"/><![CDATA[</a><br/>See <a href=']]><xsl:value-of select="concat($url,
						'results?q=mint_facet:\&#x022;', $title, '\&#x022;')"/><![CDATA['>other objects</a> from this mint.]]>
				</xsl:when>
				<xsl:when test="$type='subject'">
					<![CDATA[<a href=']]><xsl:value-of select="$href"/><![CDATA['>]]><xsl:value-of select="$href"/><![CDATA[</a>]]>
				</xsl:when>
				<xsl:when test="$type='findspot'">
					<![CDATA[Findspot - Lat: ]]><xsl:value-of select="tokenize($coordinates, '\|')[1]"/><![CDATA[, Lon: ]]><xsl:value-of select="tokenize($coordinates, '\|')[2]"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="theme">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type='object-mint'">
					<xsl:text>blue</xsl:text>
				</xsl:when>
				<xsl:when test="$type='coinType'">
					<xsl:text>ltblue</xsl:text>
				</xsl:when>
				<xsl:when test="$type='subject'">green</xsl:when>
				<xsl:otherwise>
					<xsl:text>red</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type='subject'"/>
				<xsl:when test="$type='object-mint'">
					<xsl:choose>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:date/@standardDate">
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate">
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$type='coinType'">
					<xsl:choose>
						<xsl:when test="nuds:date/@standardDate">
							<xsl:value-of select="number(nuds:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="nuds:dateRange/nuds:fromDate/@standardDate">
							<xsl:value-of select="number(nuds:dateRange/nuds:fromDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$type='findspot'">
					<xsl:choose>
						<xsl:when test="ancestor::nh:findspot/nh:deposit/nh:date/@standardDate">
							<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:fromDate/@standardDate">
							<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:fromDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type='subject'"/>
				<xsl:when test="$type='object-mint'">
					<xsl:if test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
						<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$type='coinType'">
					<xsl:if test="nuds:dateRange/nuds:toDate/@standardDate">
						<xsl:value-of select="number(nuds:dateRange/nuds:toDate/@standardDate)"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$type='findspot'">
					<xsl:choose>
						<xsl:when test="ancestor::nh:findspot/nh:deposit/nh:date/@standardDate">
							<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="number(ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:toDate/@standardDate)">
							<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:toDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- output -->
		<xsl:variable name="json"> { <xsl:if test="string($coordinates) and not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[2]"/>, "lat": <xsl:value-of
					select="tokenize($coordinates, '\|')[1]"/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", <xsl:if test="string($start)">"start": "<xsl:value-of select="$start"/>",</xsl:if>
			<xsl:if test="string($end)">"end": "<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>"<xsl:if test="string($description)">, "description":
					"<xsl:value-of select="normalize-space($description)"/>"</xsl:if><xsl:if test="string($href) or string(@xlink:href)">, "href": "<xsl:value-of select="if (string($href)) then $href
					else @xlink:href"/>"</xsl:if> } } </xsl:variable>
		<xsl:value-of select="normalize-space($json)"/>
	</xsl:template>

</xsl:stylesheet>
