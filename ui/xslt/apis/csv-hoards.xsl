<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<!-- params -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>	
	<xsl:param name="calculate" select="doc('input:request')/request/parameters/parameter[name='calculate']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name='compare']/value"/>
	<xsl:param name="exclude" select="doc('input:request')/request/parameters/parameter[name='exclude']/value"/>	
	<xsl:param name="request-uri" select="concat('http://localhost:', if (//config/server-port castable as xs:integer) then //config/server-port else '8080', substring-before(doc('input:request')/request/request-uri, 'hoards.csv'))"/>
	<xsl:variable name="url" select="/config/url"/>

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
		<xsl:variable name="counts" as="element()*">
			<counts>
				<!-- if there is a compare parameter, load get_hoard_quant with document() function -->
				<xsl:if test="string($compare) and string($calculate)">
					<xsl:for-each select="tokenize($compare, ',')">
						<xsl:copy-of
							select="document(concat($request-uri, 'get_hoard_quant?id=', ., '&amp;calculate=', if (string($role)) then $role else $element, '&amp;type=', $type, '&amp;exclude=', $exclude, if(string($lang)) then concat('&amp;lang=', $lang) else ''))"
						/>						
					</xsl:for-each>
				</xsl:if>
			</counts>
		</xsl:variable>

		<!--<xsl:copy-of select="$counts"/>-->

		<!-- display first row of CSV (hoard names) -->
		<xsl:text>"",</xsl:text>
		<xsl:for-each select="$counts//hoard">
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
		<xsl:for-each select="distinct-values($counts//name)">
			<xsl:sort data-type="{if ($calculate = 'date') then 'number' else 'text'}"/>
			<xsl:variable name="name" select="."/>

			<!-- display first column: name -->
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$name"/>
			<xsl:text>",</xsl:text>
			<!-- display the value per hoard -->
			<xsl:for-each select="$counts//hoard">
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
	</xsl:template>

</xsl:stylesheet>
