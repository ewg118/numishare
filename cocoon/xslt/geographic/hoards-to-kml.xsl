<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns="http://earth.google.com/kml/2.0" version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="field"/>
	<xsl:param name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style xmlns="" id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon49.png</href>
						</Icon>
					</IconStyle>
				</Style>

				<xsl:for-each select="//doc">
					<xsl:variable name="findspot" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[1]"/>
					<xsl:variable name="uri" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[2]"/>
					<xsl:variable name="coordinates" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[3]"/>

					<xsl:variable name="description">
						<xsl:text>&lt;a href="</xsl:text>
						<xsl:value-of select="$url"/>
						<xsl:text>id/</xsl:text>
						<xsl:value-of select="str[@name='recordId']"/>
						<xsl:text>" target="_blank"&gt;</xsl:text>
						<xsl:value-of select="str[@name='recordId']"/>
						<xsl:text>&lt;/a&gt;, closing date: </xsl:text>
						<xsl:value-of select="str[@name='closing_date_display']"/>
					</xsl:variable>

					<Placemark>
						<name>
							<xsl:value-of select="$findspot"/>
						</name>
						<description>
							<xsl:value-of select="$description"/>
						</description>
						<styleUrl>#hoard</styleUrl>
						<Point>
							<coordinates>
								<xsl:value-of select="$coordinates"/>
							</coordinates>
						</Point>
						<xsl:if test="number(int[@name='tpq_num']) and number(int[@name='taq_num'])">
							<TimeSpan>
								<begin>
									<xsl:value-of select="int[@name='tpq_num']"/>
								</begin>
								<end>
									<xsl:value-of select="int[@name='taq_num']"/>
								</end>
							</TimeSpan>
						</xsl:if>
					</Placemark>
				</xsl:for-each>
			</Document>
		</kml>
	</xsl:template>
</xsl:stylesheet>
