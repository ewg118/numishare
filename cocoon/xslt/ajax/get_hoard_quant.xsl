<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">

	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="calculate"/>
	<xsl:param name="type"/>

	<xsl:variable name="element">
		<xsl:choose>
			<xsl:when test="$calculate = 'material' or $calculate='denomination'">
				<xsl:value-of select="$calculate"/>
			</xsl:when>
			<xsl:when test="$calculate='mint' or $calculate='region'">
				<xsl:text>geogname</xsl:text>
			</xsl:when>
			<xsl:when test="$calculate='dynasty'">
				<xsl:text>famname</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>persname</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="role">
		<xsl:if test="$calculate != 'material' and $calculate != 'denomination'">
			<xsl:value-of select="$calculate"/>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name()='nudsid'])"/>
	
	<xsl:variable name="contentsDesc">
		<xsl:copy-of select="descendant::nh:contents"/>
	</xsl:variable>

	<xsl:variable name="nudsGroup">
		<nudsGroup>
			<!-- get nomisma NUDS documents with get-nuds API -->
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:for-each select="document(concat('http://nomisma.org/get-nuds?id=', $id-param))//nuds:nuds">
				<object xlink:href="http://nomisma.org/id/{nuds:nudsHeader/nuds:nudsid}">
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>

			<!-- incorporate other typeDescs which do not point to nomisma.org -->
			<xsl:for-each select="descendant::nuds:typeDesc[not(contains(@xlink:href, 'nomisma.org'))]">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<object xlink:href="{@xlink:href}">
							<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds"/>
						</object>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="total" select="sum(exsl:node-set($contentsDesc)//nh:coinGrp/@count) + count(exsl:node-set($contentsDesc)//nh:coin)"/>

		<hoard id="{$id}">
			<xsl:variable name="total-counts">
				<total-counts>
					<xsl:choose>
						<xsl:when test="string(@role)">
							<xsl:apply-templates select="exsl:node-set($nudsGroup)//*[local-name()=$element][@xlink:role=$role]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="exsl:node-set($nudsGroup)//*[local-name()=$element]"/>
						</xsl:otherwise>
					</xsl:choose>
				</total-counts>
			</xsl:variable>
			
			<xsl:for-each select="distinct-values(exsl:node-set($total-counts)//name)">
				<xsl:variable name="name" select="."/>
				<name>
					<xsl:attribute name="count">
						<xsl:variable name="count" select="sum(exsl:node-set($total-counts)//name[.=$name]/@count)"/>
						<xsl:choose>
							<xsl:when test="$type='count'">
								<xsl:value-of select="$count"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(($count div $total) * 100, '##.00')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:value-of select="$name"/>
				</name>
			</xsl:for-each>
		</hoard>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:variable name="value" select="."/>
		<xsl:variable name="source" select="ancestor::object/@xlink:href"/>
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="string($source)">
					<xsl:choose>
						<xsl:when test="exsl:node-set($contentsDesc)//nh:coin[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="count(exsl:node-set($contentsDesc)//nh:coin/nuds:typeDesc[@xlink:href=$source])"/>
						</xsl:when>
						<xsl:when test="exsl:node-set($contentsDesc)//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]">
							<xsl:value-of select="sum(exsl:node-set($contentsDesc)//nh:coinGrp[nuds:typeDesc[@xlink:href=$source]]/@count)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="count(exsl:node-set($contentsDesc)//nh:coin/nuds:typeDesc/*[local-name()=$element][.=$value]) + sum(exsl:node-set($contentsDesc)//nh:coinGrp[nuds:typeDesc/*[local-name()=$element][.=$value]]/@count)"
					/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<name>
			<xsl:attribute name="count">					
				<xsl:value-of select="$count"/>
			</xsl:attribute>
			<xsl:value-of select="$value"/>
		</name>
	</xsl:template>

</xsl:stylesheet>
