<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************** SHARED TEMPLATES AND FUNCTIONS *****************************************
	Author: Ethan Gruber
	Function: this XSLT stylesheet is included into xslt/solr.xsl.  It contains shared templates and functions that may be used in object-
	specific stylesheets for creating Solr documents
	Modification date: April 2012
-->
<xsl:stylesheet xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="nuds:typeDesc">
		<xsl:param name="recordType"/>

		<xsl:apply-templates select="nuds:date|nuds:dateRange">
			<xsl:with-param name="recordType" select="$recordType"/>
		</xsl:apply-templates>

		<xsl:for-each select="nuds:obverse | nuds:reverse">
			<xsl:variable name="side" select="substring(local-name(), 1, 3)"/>
			<xsl:for-each select="nuds:type/nuds:description">
				<xsl:if test="$recordType != 'hoard' and position() = 1">
					<field name="{$side}_type_display">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<field name="{$side}_type_text">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:for-each>
			<xsl:if test="nuds:legend">
				<xsl:if test="$recordType != 'hoard'">
					<field name="{$side}_leg_display">
						<xsl:value-of select="normalize-space(nuds:legend)"/>
					</field>
				</xsl:if>
				<field name="{$side}_leg_text">
					<xsl:value-of select="normalize-space(nuds:legend)"/>
				</field>
			</xsl:if>
		</xsl:for-each>

		<!-- *********** FACETS ************** -->

		<xsl:apply-templates select="nuds:objectType | nuds:denomination | nuds:manufacture | nuds:material"/>
		<xsl:apply-templates select="descendant::nuds:persname | descendant::nuds:corpname | descendant::nuds:geogname|descendant::nuds:famname"/>

	</xsl:template>

	<xsl:template match="nuds:objectType|nuds:denomination|nuds:manufacture|nuds:material|nuds:famname">
		<xsl:variable name="facet" select="if (local-name()='famname') then 'dynasty' else local-name()"/>

		<field name="{$facet}_facet">
			<xsl:value-of select="."/>
		</field>
		<xsl:if test="string(@xlink:href)">
			<field name="{$facet}_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:persname|nuds:corpname |*[local-name()='geogname']">
		<field name="{@xlink:role}_facet">
			<xsl:value-of select="normalize-space(.)"/>
		</field>
		<field name="{@xlink:role}_text">
			<xsl:value-of select="normalize-space(.)"/>
		</field>
		<xsl:if test="string(@xlink:href)">
			<field name="{@xlink:role}_uri">
				<xsl:value-of select="@xlink:href"/>
			</field>
		</xsl:if>
		<xsl:if test="string(@xlink:href) and (@xlink:role = 'mint' or @xlink:role = 'findspot')">
			<xsl:choose>
				<xsl:when test="contains(@xlink:href, 'geonames')">
					<xsl:variable name="href" select="@xlink:href"/>
					<xsl:variable name="value" select="."/>
					<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
					<field name="{@xlink:role}_geo">
						<xsl:value-of select="."/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$href"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="exsl:node-set($geonames)//place[@id=$href]"/>
					</field>
					<!-- insert hierarchical facets -->
					<xsl:for-each select="tokenize(exsl:node-set($geonames)//place[@id=$href]/@hierarchy, '\|')">
						<xsl:if test="not(. = $value)">
							<field name="findspot_hier">				
								<xsl:value-of select="concat('L', position(), '|', .)"/>
							</field>
							<field name="findspot_text">
								<xsl:value-of select="."/>
							</field>
						</xsl:if>
						<xsl:if test="position()=last()">
							<xsl:variable name="level" select="if (.=$value) then position() else position() + 1"/>
							<field name="findspot_hier">			
								<xsl:value-of select="concat('L', $level, '|', $value)"/>
							</field>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="contains(@xlink:href, 'nomisma.org')">
					<xsl:variable name="href" select="@xlink:href"/>
					<xsl:variable name="coordinates" select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/gml:pos"/>
					<xsl:if test="string($coordinates)">
						<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
						<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
						<!-- *_geo format is 'mint name|URI of resource|KML-compliant geographic coordinates' -->
						<field name="{@xlink:role}_geo">
							<xsl:value-of select="."/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="@xlink:href"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="concat($lon, ',', $lat)"/>
						</field>
					</xsl:if>
					<xsl:if test="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:related[contains(@rdf:resource, 'pleiades')]">
						<field name="pleiades_uri">
							<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/skos:related[contains(@rdf:resource, 'pleiades')]/@rdf:resource"/>
						</field>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- generalize refDesc for NUDS and NUDS Hoard records -->
	<xsl:template match="*[local-name()='refDesc']">
		<xsl:variable name="refs">
			<refs>
				<xsl:for-each select="*[local-name()='reference']">
					<ref>
						<xsl:call-template name="get_ref"/>
					</ref>
				</xsl:for-each>
			</refs>
		</xsl:variable>

		<xsl:for-each select="exsl:node-set($refs)//ref">
			<xsl:sort order="ascending"/>
			<field name="reference_facet">
				<xsl:value-of select="."/>
			</field>
			<xsl:if test="position() = 1">
				<field name="reference_min">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
			<xsl:if test="position() = last()">
				<field name="reference_max">
					<xsl:value-of select="."/>
				</field>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:param name="recordType"/>

		<xsl:if test="$recordType != 'hoard'">
			<field name="date_display">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
		</xsl:if>

		<xsl:if test="string(normalize-space(@standardDate))">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="@standardDate"/>
				<xsl:with-param name="recordType" select="$recordType"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:dateRange">
		<xsl:param name="recordType"/>

		<xsl:if test="$recordType != 'hoard'">
			<field name="date_display">
				<xsl:value-of select="normalize-space(nuds:fromDate)"/>
				<xsl:text> - </xsl:text>
				<xsl:value-of select="normalize-space(nuds:toDate)"/>
			</field>
		</xsl:if>

		<xsl:for-each select="*/@standardDate">
			<xsl:call-template name="get_date_hierarchy">
				<xsl:with-param name="standardDate" select="."/>
				<xsl:with-param name="recordType" select="$recordType"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_date_hierarchy">
		<xsl:param name="standardDate"/>
		<xsl:param name="recordType"/>

		<xsl:if test="number(.)">
			<xsl:variable name="year_string" select="string(abs(number(.)))"/>
			<xsl:variable name="century" select="if(number(.) &gt; 0) then ceiling(number(.) div 100) else floor(number(.) div 100)"/>
			<xsl:variable name="decade_digit" select="floor(number(substring($year_string, string-length($year_string) - 1, string-length($year_string))) div 10) * 10"/>
			<xsl:variable name="decade" select="if($decade_digit = 0) then '00' else $decade_digit"/>

			<xsl:if test="number($century)">
				<field name="century_num">
					<xsl:value-of select="$century"/>
				</field>
			</xsl:if>
			<xsl:if test="number($decade)">
				<field name="decade_num">
					<xsl:choose>
						<xsl:when test="$century &gt; 0">
							<xsl:value-of select="concat($century -1, $decade)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="($century * 100) + 100 - $decade_digit"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
			</xsl:if>
			<xsl:if test="number(.)">
				<field name="year_num">
					<xsl:value-of select="number(.)"/>
				</field>
			</xsl:if>

			<!-- add min and max, even if they are integers (for ISO dates) -->
			<xsl:if test="$recordType != 'hoard'">
				<xsl:if test="position() = 1">
					<field name="year_minint">
						<xsl:value-of select="number(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position() = last()">
					<field name="year_maxint">
						<xsl:value-of select="number(.)"/>
					</field>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="get_hoard_sort_fields">
		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,magistrate,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>

		<xsl:variable name="temp-nudsGroup">
			<nudsGroup>
				<xsl:for-each select="descendant::nuds:typeDesc">
					<xsl:choose>
						<xsl:when test="string(@xlink:href)">
							<xsl:variable name="href" select="@xlink:href"/>
							<xsl:copy-of select="exsl:node-set($nudsGroup)//nuds:typeDesc[@xlink:href=$href]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</nudsGroup>
		</xsl:variable>


		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>

			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each
				select="exsl:node-set($temp-nudsGroup)/descendant::*[local-name()=$field and local-name() !='authority'][string(.)]|exsl:node-set($temp-nudsGroup)/descendant::*[@xlink:role=$field][string(.)]">
				<xsl:sort order="ascending"/>
				<xsl:if test="position()=1">
					<field name="{$field}_min">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position()=last()">
					<field name="{$field}_max">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_coin_sort_fields">
		<xsl:param name="typeDesc"/>
		<!-- sortable fields -->
		<xsl:variable name="sort-fields">
			<xsl:text>artist,authority,deity,denomination,dynasty,issuer,maker,manufacture,material,mint,portrait,region</xsl:text>
		</xsl:variable>

		<xsl:for-each select="tokenize($sort-fields, ',')">
			<xsl:variable name="field" select="."/>
			<!-- for each sortable field which is a multiValued field in Solr (a facet), grab the min and max values -->
			<xsl:for-each select="exsl:node-set($typeDesc)/descendant::*[local-name()=$field and local-name() !='authority']|exsl:node-set($typeDesc)/descendant::*[@xlink:role=$field]">
				<xsl:sort order="ascending"/>
				<xsl:variable name="name" select="if(@xlink:role) then @xlink:role else local-name()"/>
				<xsl:if test="position()=1">
					<field name="{$name}_min">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<xsl:if test="position() = last()">
					<field name="{$name}_max">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="get_ref">
		<xsl:choose>
			<xsl:when test="*[local-name()='objectXMLWrap']/mods:modsCollection">
				<xsl:value-of select="*[local-name()='objectXMLWrap']/mods:modsCollection/mods:mods/@ID"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string(*[local-name()='title'])">
						<xsl:value-of select="normalize-space(*[local-name()='title'])"/>
						<xsl:if test="string(*[local-name()='identifier'])">
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space(*[local-name()='identifier'])"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
