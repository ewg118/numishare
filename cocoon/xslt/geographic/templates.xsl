<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:gml="http://www.opengis.net/gml/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="http://code.google.com/p/numishare/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="exsl gml skos nm rdf nuds nh cinclude xlink numishare res" version="2.0">
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

	<xsl:template name="json">
		<xsl:text> [ </xsl:text>
		<xsl:choose>
			<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
				<xsl:apply-templates select="/content/nuds:nuds" mode="json"/>
			</xsl:when>
			<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
				<xsl:apply-templates select="/content/nh:nudsHoard" mode="json"/>
			</xsl:when>
		</xsl:choose>
		<xsl:text> ] </xsl:text>
	</xsl:template>

	<xsl:template match="nuds:nuds" mode="kml">
		<!-- create mint points -->
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<!-- create findspot points (for physical coins -->
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<!-- gather associated hoards from Metis is available -->
		<xsl:if test="string($sparql_endpoint)">
			<cinclude:include src="cocoon:/widget?uri={concat('http://numismatics.org/ocre/', 'id/', $id)}&amp;template=kml"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:nuds" mode="json">
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">object-mint</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>


		<!-- gather associated hoards from Metis is available -->
		<xsl:choose>
			<xsl:when test="string($sparql_endpoint)">
				<xsl:call-template name="numishare:getJsonFindspots">
					<xsl:with-param name="uri" select="concat('http://numismatics.org/ocre/', 'id/', $id)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='findspot'][string(@xlink:href)]|descendant::nuds:findspotDesc[string(@xlink:href)]">
					<xsl:call-template name="getJsonPoint">
						<xsl:with-param name="href" select="@xlink:href"/>
						<xsl:with-param name="type">findspot</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nh:nudsHoard" mode="kml">
		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="styleUrl">#hoard</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<!-- commenting out unique portion: [not(.=preceding::nuds:geogname)] -->
			<xsl:call-template name="getPlacemark">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">mapped</xsl:with-param>
				<xsl:with-param name="styleUrl">#mint</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nh:nudsHoard" mode="json">
		<xsl:variable name="all-dates">
			<dates>
				<xsl:for-each select="descendant::nuds:typeDesc">
					<xsl:choose>
						<xsl:when test="string(@xlink:href)">
							<xsl:variable name="href" select="@xlink:href"/>
							<xsl:for-each select="exsl:node-set($nudsGroup)//object[@xlink:href=$href]/descendant::*/@standardDate">
								<xsl:if test="number(.)">
									<date>
										<xsl:value-of select="number(.)"/>
									</date>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="descendant::*/@standardDate">
								<xsl:if test="number(.)">
									<date>
										<xsl:value-of select="number(.)"/>
									</date>
								</xsl:if>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</dates>
		</xsl:variable>
		<xsl:variable name="dates">
			<dates>
				<xsl:for-each select="distinct-values(exsl:node-set($all-dates)//date)">
					<xsl:sort data-type="number"/>
					<date>
						<xsl:value-of select="number(.)"/>
					</date>
				</xsl:for-each>
			</dates>
		</xsl:variable>

		<xsl:for-each select="descendant::nh:geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">findspot</xsl:with-param>
				<xsl:with-param name="dates" select="$dates"/>
			</xsl:call-template>
			<xsl:if test="count(exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]) &gt; 0">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="exsl:node-set($nudsGroup)/descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<xsl:call-template name="getJsonPoint">
				<xsl:with-param name="href" select="@xlink:href"/>
				<xsl:with-param name="type">mint</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getJsonPoint">
		<xsl:param name="href"/>
		<xsl:param name="type"/>
		<xsl:param name="dates"/>
		<!-- generate json values -->
		<xsl:variable name="coordinates">
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="lat" select="exsl:node-set($geonames_data)//lat"/>
					<xsl:variable name="lon" select="exsl:node-set($geonames_data)//lng"/>
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
					<xsl:variable name="coords" select="exsl:node-set($rdf)//*[@rdf:about=$href]/gml:pos"/>
					<xsl:choose>
						<xsl:when test="string($coords)">
							<xsl:variable name="lat" select="substring-before($coords, ' ')"/>
							<xsl:variable name="lon" select="substring-after($coords, ' ')"/>
							<xsl:value-of select="concat($lat, '|', $lon)"/>
						</xsl:when>
						<xsl:otherwise>NULL</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="$type='mint'">
					<xsl:value-of select="ancestor::nuds:nuds/nuds:descMeta/nuds:title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="$type='mint'">
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
				</xsl:when>
				<xsl:when test="$type='object-mint'"/>
				<xsl:otherwise>
					<xsl:text>Findspot - </xsl:text>
					<xsl:text>Lat: </xsl:text>
					<xsl:value-of select="tokenize($coordinates, '\|')[1]"/>
					<xsl:text>, Lon: </xsl:text>
					<xsl:value-of select="tokenize($coordinates, '\|')[2]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="theme">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type = 'object-mint'">
					<xsl:text>blue</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>red</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type='object-mint'">
					<xsl:choose>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:date/@standardDate">
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:date/@standardDate)"/>
						</xsl:when>
						<xsl:when test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate">
							<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:fromDate/@standardDate)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="count(exsl:node-set($dates)/dates/date) &gt; 0">
						<xsl:value-of select="exsl:node-set($dates)/dates/date[1]"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:choose>
				<xsl:when test="$type='mint' or $type='object-mint'">
					<xsl:if test="ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate">
						<xsl:value-of select="number(ancestor::nuds:typeDesc/nuds:dateRange/nuds:toDate/@standardDate)"/>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="count(exsl:node-set($dates)/dates/date) &gt; 0">
						<xsl:value-of select="exsl:node-set($dates)/dates/date[last()]"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- output --> { <xsl:if test="not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[2]"/>, "lat": <xsl:value-of
				select="tokenize($coordinates, '\|')[1]"/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", "start": "<xsl:value-of select="$start"/>", <xsl:if test="string($end)">"end":
				"<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>"<xsl:if test="string($description)">, "description": "<xsl:value-of
				select="$description"/>"</xsl:if> } } </xsl:template>

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
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel)">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:prefLabel"/>
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
					<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coordinates" select="exsl:node-set($rdf)//*[@rdf:about=$href]/descendant::gml:pos[1]"/>
					<xsl:if test="string($coordinates)">
						<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
						<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
						<Point>
							<coordinates>
								<xsl:value-of select="concat($lon, ',', $lat)"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<!-- display timespan -->
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
		</Placemark>
	</xsl:template>

	<!-- get findspots from SPARQL endpoint, returned in JSON -->
	<xsl:template name="numishare:getJsonFindspots">
		<xsl:param name="uri"/>

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
		<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
		<xsl:apply-templates select="document($service)/res:sparql" mode="json"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="json">
		<xsl:if test="count(descendant::res:result/res:binding[@name='findspot']) &gt; 0">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="descendant::res:result/res:binding[@name='findspot']" mode="json"/>
	</xsl:template>

	<xsl:template match="res:binding[@name='findspot']" mode="json">
		<xsl:variable name="coordinates">
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="contains(child::res:uri, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:uri, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, '|', exsl:node-set($geonames_data)//lat)"/>
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
          					<span><a href=']]><xsl:value-of select="parent::node()/res:binding[@name='uri']/res:uri"/><![CDATA[' target='_blank'>]]><xsl:value-of
				select="parent::node()/res:binding[@name='title']/res:literal"/><![CDATA[</a>]]>
			<xsl:if test="string(parent::node()/res:binding[@name='burial']/res:literal)">
				<![CDATA[- closing date: ]]><xsl:value-of select="numishare:normalizeYear(number(parent::node()/res:binding[@name='burial']/res:literal))"/>
			</xsl:if>
			<![CDATA[</span>
        				]]>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<xsl:variable name="start">
			<xsl:value-of select="number(parent::node()/res:binding[@name='burial']/res:literal)"/>
		</xsl:variable>
		<xsl:variable name="end"/>
		<!-- output --> { <xsl:if test="not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[1]"/>, "lat": <xsl:value-of
				select="tokenize($coordinates, '\|')[2]"/>},</xsl:if> "title": "<xsl:value-of select="$title"/>", "start": "<xsl:value-of select="$start"/>", <xsl:if test="string($end)">"end":
					"<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>", "infoHtml": "<xsl:value-of select="normalize-space($description)"/>" } } <xsl:if
			test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
