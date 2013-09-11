<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	xmlns="http://earth.google.com/kml/2.0" version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>
	
	<xsl:param name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style id="ANSStyle">
					<BalloonStyle>
						<bgColor>#F7F6ED</bgColor>
						<text><![CDATA[
					     <table border="0" cellpadding="0" cellspacing="0" width="480"><tr><td><h3>$[name]</h3>
						<br/>					      
					    $[description]
					      <br/></td></tr></table>
					      ]]></text>
					</BalloonStyle>
				</Style>
				<xsl:apply-templates select="descendant::doc"/>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="doc">		
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
				<li><b>Object Type: </b>]]><xsl:value-of select="str[@name='objectType_facet']"/><![CDATA[</li>				
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
				<xsl:if test="arr[@name='weight_num']"><![CDATA[
					<li><b>Weight: </b>]]><xsl:value-of select="arr[@name='weight_num']/float"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="str[@name='axis_num']"><![CDATA[
					<li><b>Axis: </b>]]><xsl:value-of select="str[@name='axis_num']"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="str[@name='findspot_facet']"><![CDATA[
					<li><b>Findspot: </b>]]><xsl:value-of select="str[@name='findspot_facet']"/><![CDATA[</li>]]>
					
				</xsl:if>
				<xsl:if test="arr[@name='reference_display']"><![CDATA[
					<li><b>Reference(s): </b>]]>
					<xsl:for-each select="arr[@name='reference_display']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each><![CDATA[</li>]]>
					
				</xsl:if>
				<![CDATA[</ul>
				<![CDATA[<a href="]]><xsl:value-of select="str[@name='mint_uri']"/><![CDATA[">View Mint</a><br/>]]>
				<![CDATA[<a href="]]><xsl:value-of select="concat($url, 'id/', str[@name='identifier_display'])"/><![CDATA[">View Item</a>]]>				
			</description>
			<styleUrl>#ANSStyle</styleUrl>
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
