<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:datetime="http://exslt.org/dates-and-times">
	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="descendant::work"/>
		</add>
	</xsl:template>

	<xsl:template match="work">
		<doc>
			<field name="id">
				<xsl:value-of select="normalize-space(@id)"/>
			</field>
			<field name="timestamp">
				<xsl:value-of select="concat(datetime:dateTime(), 'Z')"/>
			</field>
			<field name="doc_code">
				<xsl:value-of select="normalize-space(@id)"/>
			</field>
			<field name="source_meta">
				<xsl:text>vra</xsl:text>
			</field>
			<xsl:for-each
				select="locationSet/location[@type='repository' or @type='owner']/name[not(@type='geographic')]">
				<field name="institution_facet">
					<xsl:value-of select="normalize-space(.)"/>

				</field>
			</xsl:for-each>
			<field name="collection_facet">
				<xsl:value-of select="normalize-space(@source)"/>
			</field>

			<xsl:if test="string(normalize-space(descendant::refid[@type='accession']))">
				<field name="identifier_text">
					<xsl:value-of select="normalize-space(descendant::refid[@type='accession'])"/>
				</field>
				<field name="identifier_display">
					<xsl:value-of select="normalize-space(descendant::refid[@type='accession'])"/>
				</field>
			</xsl:if>
			<field name="title_display">
				<xsl:value-of select="normalize-space(titleSet/display)"/>
			</field>
			<xsl:if test="string(normalize-space(dateSet/display))">
				<field name="date_display">
					<xsl:value-of select="normalize-space(dateSet/display)"/>
				</field>
			</xsl:if>
			<xsl:for-each select="dateSet/date/earliestDate | dateSet/date/latestDate">
				<field name="year_num">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
				<field name="century_num">
					<xsl:choose>
						<xsl:when test="contains(., '-')">
							<xsl:text>-</xsl:text>
							<xsl:variable name="value"
								select="number(substring-after(normalize-space(.), '-'))"/>
							<xsl:value-of select="ceiling($value div 100)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="value" select="number(normalize-space(.))"/>
							<xsl:value-of select="ceiling($value div 100)"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
			</xsl:for-each>
			<xsl:for-each select="materialSet/material">
				<field name="material_facet">
					<xsl:value-of select="(.)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="worktypeSet/worktype">
				<field name="objectType_facet">
					<xsl:value-of select="(.)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="techniqueSet/technique">
				<field name="technique_facet">
					<xsl:value-of select="(.)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="styleSet/style">
				<field name="style_facet">
					<xsl:value-of select="(.)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="measurementsSet/measurements">
				<xsl:variable name="value" select="number(normalize-space(.))"/>
				<xsl:choose>
					<xsl:when
						test="@type='height' or @type='width' or @type='depth' or @type='length'">
						<field name="dimensions_num">
							<xsl:choose>
								<xsl:when test="@unit = 'm'">
									<xsl:value-of select="$value * 1000"/>
								</xsl:when>
								<xsl:when test="@unit = 'cm'">
									<xsl:value-of select="$value * 10"/>
								</xsl:when>
								<xsl:when test="@unit = 'mm'">
									<xsl:value-of select="$value"/>
								</xsl:when>
							</xsl:choose>
						</field>
					</xsl:when>
					<xsl:when test="@type='weight'">
						<field name="weight_num">
							<xsl:choose>
								<xsl:when test="@unit = 'kg'">
									<xsl:value-of select="$value * 1000"/>
								</xsl:when>
								<xsl:when test="@unit = 'g'">
									<xsl:value-of select="normalize-space(.)"/>
									<xsl:value-of select="$value"/>
								</xsl:when>
							</xsl:choose>
						</field>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>

			<xsl:for-each
				select="descendant::location[@type='creation'] | descendant::location[@type='discovery'] | descendant::location[@type='performance'] | descendant::location[@type='publication'] | descendant::location[@type='site']">
				<xsl:apply-templates select="name[@type='geographic']" mode="index_terms"/>
				<xsl:apply-templates select="name[@type='corporate']" mode="index_terms"/>
			</xsl:for-each>

			<field name="origination_display">
				<xsl:value-of select="normalize-space(descendant::locationSet/display)"/>
			</field>

			<xsl:apply-templates
				select="descendant::agent/name[@type='personal'] | descendant::agent/name[@type='family'] | descendant::agent/name[@type='corporate']"/>

			<xsl:for-each
				select="descendant::subject/term[@type='conceptTopic'] | descendant::subject/term[@type='descriptiveTopic'] | descendant::subject/term[@type='iconographicTopic'] | descendant::subject/term[@type='otherTopic']">
				<field name="subject_facet">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:for-each>

			<xsl:for-each select="//imageSet/image[@source='thumb']">
				<field name="thumbnail_image">
					<xsl:value-of select="normalize-space(@href)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="//imageSet/image[@source='screen']">
				<field name="reference_image">
					<xsl:value-of select="normalize-space(@href)"/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="//imageSet/image[@source='large']">
				<field name="large_image">
					<xsl:value-of select="normalize-space(@href)"/>
				</field>
			</xsl:for-each>



			<field name="fulltext">
				<xsl:for-each select="descendant-or-self::text()">
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="location/name" mode="index_terms">
		<xsl:choose>
			<xsl:when test="@type='geographic'">
				<xsl:if test="string(normalize-space(@extent))">
					<xsl:variable name="category">
						<xsl:choose>
							<xsl:when test="@extent='city'">city_facet</xsl:when>
							<xsl:when test="@extent='region'">region_facet</xsl:when>
							<xsl:when test="@extent='state'">state_facet</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<field name="{$category}">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:if>
				<field name="geogname_text">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:when>
			<xsl:when test="@type='corporate'">
				<field name="corpname_facet">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="agent/name">
		<xsl:variable name="category">
			<xsl:choose>
				<xsl:when test="@type='personal'">
					<xsl:text>persname_facet</xsl:text>
				</xsl:when>
				<xsl:when test="@type='family'">
					<xsl:text>dynasty_facet</xsl:text>
				</xsl:when>
				<xsl:when test="@type='corporate'">
					<xsl:text>corpname_facet</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<field name="{$category}">
			<xsl:value-of select="(.)"/>
		</field>
		<xsl:if test="@type='personal'">
			<field name="persname_text">
				<xsl:value-of select="(.)"/>
			</field>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
