<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns="http://earth.google.com/kml/2.0" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<xsl:for-each select="//lst[@name='mint_geo']/int">
					<xsl:variable name="mint" select="tokenize(@name, '\|')[1]"/>
					<xsl:variable name="uri" select="tokenize(@name, '\|')[2]"/>
					<xsl:variable name="coordinates" select="tokenize(@name, '\|')[3]"/>
					
					<Placemark>
						<name>
							<xsl:value-of select="$mint"/>
						</name>
						<description>
							<xsl:value-of select="$uri"/>
						</description>
						<Point>
							<coordinates>
								<xsl:value-of select="$coordinates"/>
							</coordinates>
						</Point>
					</Placemark>
				</xsl:for-each>
			</Document>
		</kml>
	</xsl:template>
</xsl:stylesheet>
