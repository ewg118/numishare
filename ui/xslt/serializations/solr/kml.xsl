<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns="http://earth.google.com/kml/2.0" version="2.0">
	
	<!-- variables and parameters -->
	<xsl:param name="mode" select="//lst[@name='params']/str[@name='mode']"/>
	<xsl:variable name="url" select="/content/config/url"/>
	
	<xsl:template match="/">
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
				<Style id="findspot">
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
					<xsl:when test="count(descendant::doc) &gt; 0">
						<xsl:choose>
							<xsl:when test="$mode='query'">
								<xsl:apply-templates select="descendant::doc" mode="query"/>
							</xsl:when>
							<xsl:when test="$mode='hoard'">
								<xsl:apply-templates select="descendant::doc" mode="hoard"/>
							</xsl:when>
						</xsl:choose>
						
					</xsl:when>
					<xsl:when test="//lst[contains(@name, '_geo')]">
						<xsl:apply-templates select="//lst[contains(@name, '_geo')]"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>
	<xsl:template match="lst">
		<xsl:variable name="style" select="substring-before(@name, '_')"/>
		<xsl:for-each select="int">
			<xsl:variable name="value" select="tokenize(@name, '\|')[1]"/>
			<xsl:variable name="uri" select="tokenize(@name, '\|')[2]"/>
			<xsl:variable name="coordinates" select="tokenize(@name, '\|')[3]"/>
			<xsl:if test="string-length($coordinates) &gt; 1">
				<Placemark>
					<name>
						<xsl:value-of select="$value"/>
					</name>
					<description>
						<xsl:value-of select="$uri"/>
					</description>
					<styleUrl>
						<xsl:value-of select="concat('#', $style)"/>
					</styleUrl>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</Placemark>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="doc" mode="hoard">
		<xsl:variable name="value" select="tokenize(arr[@name='findspot_geo']/str[1], '\|')[1]"/>
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
				<xsl:value-of select="str[@name='title_display']"/>
			</name>
			<description>
				<xsl:value-of select="$description"/>
			</description>
			<styleUrl>#findspot</styleUrl>
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
	</xsl:template>
	
	<xsl:template match="doc" mode="query">
		<Placemark id="{str[@name='recordId']}">
			<name>
				<xsl:value-of select="str[@name='title_display']"/>
			</name>
			
			<description>
				<xsl:if test="str[@name='imagesavailable'] = 'true'">
					<![CDATA[
					<img src="]]><xsl:value-of select="str[@name='thumbnail_obv']"/><![CDATA["/>]]>
				</xsl:if>
				<![CDATA[
				<ul style="list-style-type:none">
				<li><b>Object Type: </b>]]><xsl:value-of select="arr[@name='objectType_facet']/str"/><![CDATA[</li>				
				]]>
				<xsl:if test="arr[@name='department_facet']"><![CDATA[
					<li><b>Department: </b>]]><xsl:value-of select="arr[@name='department_facet']/str"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="str[@name='obv_leg_display'] or str[@name='obv_type_display']">					
					<![CDATA[
					<li><b>Obverse: </b>]]>						
					<xsl:value-of select="str[@name='obv_type_display']"/>								
					<xsl:if test="str[@name='obv_leg_display'] and str[@name='obv_type_display']">
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="str[@name='obv_leg_display']"/>
					<![CDATA[</li>]]>
				</xsl:if>
				<xsl:if test="str[@name='rev_leg_display'] or str[@name='rev_type_display']">					
					<![CDATA[
					<li><b>Reverse: </b>]]>						
					<xsl:value-of select="str[@name='rev_type_display']"/>								
					<xsl:if test="str[@name='rev_leg_display'] and str[@name='rev_type_display']">
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:value-of select="str[@name='rev_leg_display']"/>
					<![CDATA[</li>]]>
				</xsl:if>		
				<xsl:if test="float[@name='weight_num']"><![CDATA[
					<li><b>Weight: </b>]]><xsl:value-of select="float[@name='weight_num']"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="int[@name='axis_num']"><![CDATA[
					<li><b>Axis: </b>]]><xsl:value-of select="int[@name='axis_num']"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="arr[@name='findspot_facet']/str"><![CDATA[
					<li><b>Findspot: </b>]]><xsl:value-of select="arr[@name='findspot_facet']/str"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="arr[@name='reference_facet']"><![CDATA[
					<li><b>Reference(s): </b>]]>
					<xsl:for-each select="arr[@name='reference_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each><![CDATA[</li>]]>
					
				</xsl:if>
				<![CDATA[</ul>
				<![CDATA[<a href="]]><xsl:value-of select="arr[@name='mint_uri']/str"/><![CDATA[">View Mint</a><br/>]]>
				<![CDATA[<a href="]]><xsl:value-of select="concat($url, 'id/', str[@name='recordId'])"/><![CDATA[">View Item</a>]]>				
			</description>
			<styleUrl>#mint</styleUrl>
			<xsl:for-each select="arr[@name='mint_geo']/str">
				<xsl:variable name="coordinates" select="tokenize(., '\|')[3]"/>
				<Point>
					<coordinates>
						<xsl:value-of select="$coordinates"/>
					</coordinates>
				</Point>
			</xsl:for-each>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
