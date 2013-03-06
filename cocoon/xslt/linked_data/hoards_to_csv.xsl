<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xs="http://www.w3.org/2001/XMLSchema"  xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="text" encoding="UTF-8"/>
	
	<!-- params -->
	<xsl:variable name="url">
		<xsl:value-of select="//config/url"/>
	</xsl:variable>
	
	<xsl:param name="lang"/>
	<xsl:variable name="defaultLang" select="if (string($lang)) then $lang else 'en'"/>
	<xsl:param name="calculate"/>
	<xsl:param name="compare"/>
	<xsl:param name="type"/>
	<xsl:param name="exclude"/>
	
	<xsl:template match="/">
		<xsl:for-each select="tokenize($calculate, ',')">
			<xsl:variable name="element">
				<xsl:choose>
					<xsl:when test=". = 'material' or .='denomination'">
						<xsl:value-of select="$calculate"/>
					</xsl:when>
					<xsl:when test=".='mint' or .='region'">
						<xsl:text>geogname</xsl:text>
					</xsl:when>
					<xsl:when test=".='dynasty'">
						<xsl:text>famname</xsl:text>
					</xsl:when>	
					<xsl:when test=".='coinType'">
						<xsl:text>coinType</xsl:text>
					</xsl:when>
					<xsl:when test=".='date'">
						<xsl:text>date</xsl:text>
					</xsl:when>					
					<xsl:otherwise>
						<xsl:text>persname</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="role">
				<xsl:if test="$calculate != 'material' and $calculate != 'denomination' and $calculate != 'date' and $calculate != 'coinType'">
					<xsl:value-of select="$calculate"/>
				</xsl:if>
			</xsl:variable>
			
			<xsl:call-template name="render-csv">		
				<xsl:with-param name="element" select="$element"/>
				<xsl:with-param name="role" select="$role"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="render-csv">
		<xsl:param name="element"/>
		<xsl:param name="role"/>		
		<xsl:variable name="counts">
			<counts>
				<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
				<xsl:if test="string($compare) and string($calculate)">
					<xsl:for-each select="tokenize($compare, ',')">
						<xsl:copy-of select="document(concat($url, 'get_hoard_quant?id=', ., '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude))"/>
					</xsl:for-each>
				</xsl:if>
			</counts>
		</xsl:variable>
		
		<!--<xsl:copy-of select="$counts"/>-->
		
		<!-- display first row of CSV (hoard names) -->
		<xsl:text>"",</xsl:text>
		<xsl:for-each select="exsl:node-set($counts)//hoard">
			<xsl:sort select="@id"/>
			<xsl:text>"</xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:text>"</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<!-- insert line break -->
		<xsl:text>
</xsl:text>
		<!-- list distinct names -->
		<xsl:for-each select="distinct-values(exsl:node-set($counts)//name)">
			<xsl:sort data-type="{if ($calculate = 'date') then 'number' else 'text'}"/>
			<xsl:variable name="name" select="."/>
			
			<!-- display first column: name -->
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$name"/>
			<xsl:text>",</xsl:text>
			<!-- display the value per hoard -->
			<xsl:for-each select="exsl:node-set($counts)//hoard">
				<xsl:sort select="@id"/>
				<xsl:text>"</xsl:text>
				<xsl:value-of select="if (number(name[.=$name]/@count)) then name[.=$name]/@count else 0"/>
				<xsl:text>"</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<!-- insert line break -->
			<xsl:text>
</xsl:text>
		</xsl:for-each>
		
		<!--<xsl:copy-of select="$counts"/>-->
	</xsl:template>
	
</xsl:stylesheet>
