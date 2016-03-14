<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="kml">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="mapped">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="subject">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<xsl:choose>
					<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
						<xsl:apply-templates select="/content/nuds:nuds" mode="kml"/>
					</xsl:when>
					<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
						<xsl:apply-templates select="/content/nh:nudsHoard" mode="kml"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>
	<xsl:template match="nuds:nuds" mode="kml">
		<!-- create mint points -->
		<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<!-- create findspot points (for physical coins -->
		<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#subject</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<!-- gather associated hoards from Nomisma is available -->
		<xsl:if test="string($sparql_endpoint)">
			<xsl:variable name="service" select="concat($request-uri, 'sparql?uri=', //config/uri_space, $id, '&amp;template=kml')"/>
			<xsl:copy-of select="document($service)//*:Placemark"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="nh:nudsHoard" mode="kml">
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$nudsGroup/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<!-- commenting out unique portion: [not(.=preceding::nuds:geogname)] -->
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">mapped</xsl:with-param>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getPlacemark">
		<xsl:param name="href"/>
		<xsl:param name="type"/>
		<xsl:param name="styleUrl"/>
		<xsl:variable name="label">
			<!-- display the title (coin type reference) for hoards, place name for other points -->
			<xsl:choose>
				<xsl:when test="$type='mapped'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:when test="local-name()='findspotDesc'">
					<xsl:choose>
						<xsl:when test="contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string($rdf/*[@rdf:about=$href]/skos:prefLabel)">
									<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$href"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="contains($href, 'coinhoards.org')">
							<xsl:choose>
								<xsl:when test="string($rdf/*[@rdf:about=$href]/skos:prefLabel)">
									<xsl:value-of select="$rdf/*[@rdf:about=$href]/skos:prefLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$href"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<xsl:choose>
				<xsl:when test="$type='mapped'">
					<description>
						<xsl:value-of select="."/>
						<!-- display date -->
						<xsl:if test="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date or ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange">
							<xsl:text>, </xsl:text>
							<xsl:choose>
								<xsl:when test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date)">
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:date"/>
								</xsl:when>
								<xsl:when test="string(ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange)">
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:fromDate"/>
									<xsl:text> - </xsl:text>
									<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:typeDesc/nuds:dateRange/nuds:toDate"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</description>
				</xsl:when>
				<xsl:otherwise>
					<description>
						<![CDATA[
          					<span><a href="]]><xsl:value-of select="$href"/><![CDATA[" target="_blank">]]><xsl:value-of select="$label"/><![CDATA[</a>]]>
						<![CDATA[</span>
        				]]>
					</description>
				</xsl:otherwise>
			</xsl:choose>
			<styleUrl>
				<xsl:value-of select="$styleUrl"/>
			</styleUrl>
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
					<xsl:variable name="geonames_data" as="element()*">
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
					</xsl:variable>
					<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coordinates">
						<xsl:if test="$rdf//*[@rdf:about=concat($href, '#this')]/geo:long and $rdf//*[@rdf:about=concat($href, '#this')]/geo:lat">true</xsl:if>
					</xsl:variable>
					<xsl:if test="$coordinates='true'">
						<Point>
							<coordinates>
								<xsl:value-of select="concat($rdf//*[@rdf:about=concat($href, '#this')]/geo:long, ',', $rdf//*[@rdf:about=concat($href, '#this')]/geo:lat)"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
				<xsl:when test="contains($href, 'coinhoards.org')">
					<xsl:variable name="findspotUri" select="$rdf//*[@rdf:about=$href]/nmo:hasFindspot/@rdf:resource"/>

					<xsl:if test="string-length($findspotUri) &gt; 0">
						<Point>
							<coordinates>
								<xsl:value-of select="concat($rdf//*[@rdf:about=$findspotUri]/geo:long, ',', $rdf//*[@rdf:about=$findspotUri]/geo:lat)"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<!-- display timespan -->
			<xsl:choose>
				<xsl:when test="$styleUrl='#hoard'">
					<xsl:choose>
						<xsl:when test="ancestor::nh:findspot/nh:deposit/nh:date/@standardDate">
							<TimeStamp>
								<when>
									<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:date/@standardDate)"/>
								</when>
							</TimeStamp>
						</xsl:when>
						<xsl:when test="ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:fromDate/@standardDate and ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:toDate/@standardDate">
							<TimeSpan>
								<begin>
									<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:fromDate/@standardDate)"/>
								</begin>
								<end>
									<xsl:value-of select="number(ancestor::nh:findspot/nh:deposit/nh:dateRange/nh:toDate/@standardDate)"/>
								</end>
							</TimeSpan>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:date/@standardDate">
							<TimeStamp>
								<when>
									<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:date/@standardDate)"/>
								</when>
							</TimeStamp>
						</xsl:when>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate and ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
							<TimeSpan>
								<begin>
									<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>
								</begin>
								<end>
									<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/>
								</end>
							</TimeSpan>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
