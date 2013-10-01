<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:exsl="http://exslt.org/common" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml" xmlns:skos="http://www.w3.org/2004/02/skos/core#" version="2.0" >
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="nuds:nuds"/>
		</add>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<doc>
			<field name="id">
				<xsl:value-of select="nuds:control/nuds:recordId"/>
			</field>
			<field name="recordType">
				<xsl:value-of select="@recordType"/>
			</field>
			<field name="timestamp">
				<xsl:value-of select="if(contains(datetime:dateTime(), 'Z')) then datetime:dateTime() else concat(datetime:dateTime(), 'Z')"/>
			</field>

			<xsl:apply-templates select="nuds:descMeta"/>
			<xsl:apply-templates select="nuds:digRep"/>

			<field name="fulltext">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>	
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="nuds:descMeta">
		<field name="title_display">
			<xsl:value-of select="normalize-space(nuds:title)"/>
		</field>				
		<xsl:apply-templates select="nuds:typeDesc"/>
		<xsl:apply-templates select="nuds:adminDesc"/>		
	</xsl:template>

	<xsl:template match="nuds:digRep">
		<xsl:apply-templates select="mets:fileSec"/>
	</xsl:template>
	
	<xsl:template match="mets:fileSec">
		<xsl:for-each select="mets:fileGrp[@USE='obverse' or @USE='reverse']">
			<xsl:variable name="side" select="substring(@USE, 1, 3)"/>
			<xsl:for-each select="mets:file">
				<field name="{@USE}_{$side}">
					<xsl:value-of select="mets:FLocat/@xlink:href"/>
				</field>
			</xsl:for-each>
		</xsl:for-each>
		<field name="imagesavailable">true</field>
	</xsl:template>

	<xsl:template match="nuds:typeDesc">
		<xsl:variable name="binding">
			<xsl:choose>
				<xsl:when test="string(@xlink:href)">
					<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:apply-templates select="exsl:node-set($binding)/nuds:typeDesc/nuds:date"/>

		<xsl:for-each select="exsl:node-set($binding)/descendant::nuds:persname | exsl:node-set($binding)/descendant::nuds:corpname | exsl:node-set($binding)/descendant::nuds:geogname">			
			<field name="{@xlink:role}_text">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:for-each>

		<xsl:for-each select="exsl:node-set($binding)/nuds:typeDesc/nuds:obverse | exsl:node-set($binding)/nuds:typeDesc/nuds:reverse">
			<xsl:variable name="side" select="substring(name(), 1, 3)"/>
			<xsl:if test="nuds:type">
				<field name="{$side}_type_display">
					<xsl:value-of select="normalize-space(nuds:type)"/>
				</field>
				<field name="type_text">
					<xsl:value-of select="normalize-space(nuds:type)"/>
				</field>
			</xsl:if>
			<xsl:if test="nuds:legend">
				<field name="{$side}_leg_display">
					<xsl:value-of select="normalize-space(nuds:legend)"/>
				</field>
				<field name="legend_text">
					<xsl:value-of select="normalize-space(nuds:legend)"/>
				</field>
			</xsl:if>
		</xsl:for-each>
		
		<field name="fulltext">
			<xsl:for-each select="exsl:node-set($binding)/descendant-or-self::text()">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>							
		</field>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<xsl:if test="nuds:identifier">
			<field name="identifier_display">
				<xsl:value-of select="normalize-space(nuds:identifier)"/>
			</field>
			<field name="identifier_text">
				<xsl:value-of select="normalize-space(nuds:identifier)"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:date">
		<field name="date_display">
			<xsl:value-of select="normalize-space(.)"/>
		</field>
	</xsl:template>
	
	<xsl:template match="nuds:dateRange">
		<field name="date_display">
			<xsl:value-of select="normalize-space(nuds:fromDate)"/>
			<xsl:text> - </xsl:text>
			<xsl:value-of select="normalize-space(nuds:toDate)"/>
		</field>
	</xsl:template>
</xsl:stylesheet>
