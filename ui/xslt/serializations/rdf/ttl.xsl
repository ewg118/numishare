<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="/rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>
	
	<xsl:variable name="rdf" as="node()*">
		<xsl:copy-of select="/rdf:RDF"/>
	</xsl:variable>
	
	<xsl:template match="/rdf:RDF">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:variable name="prefix">
				<xsl:text>@prefix </xsl:text>
				<xsl:value-of select="@prefix"/>
				<xsl:text>: &lt;</xsl:text>
				<xsl:value-of select="@uri"/>
				<xsl:text>&gt;</xsl:text>
				<xsl:text> .</xsl:text>
			</xsl:variable>
			
			<xsl:value-of select="concat(normalize-space($prefix), '&#xA;')"/>
		</xsl:for-each>
		<xsl:apply-templates select="*" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="root">
		<xsl:variable name="uri" select="@rdf:about"/>

		<xsl:variable name="about">
			<xsl:choose>
				<xsl:when test="$namespaces//namespace[contains($uri, @uri)]">
					<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
					<xsl:text> a </xsl:text>
					<xsl:value-of select="name()"/>
					<xsl:text>;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&lt;</xsl:text>
					<xsl:value-of select="$uri"/>
					<xsl:text>&gt;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:variable>
		
		<xsl:value-of select="concat('&#xA;', normalize-space($about), '&#xA;')"/>
		
		<xsl:variable name="count" select="count(distinct-values(*[not(child::*)]/name()))"/>
		<xsl:for-each select="distinct-values(*[not(child::*)]/name())">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="name" select="."/>		
			<xsl:value-of select="concat('&#x9;', $name)"/>			
			<xsl:apply-templates select="$rdf//*[@rdf:about=$uri]/*[name()=$name]" mode="predicate">
				<xsl:with-param name="position" select="$position"/>
				<xsl:with-param name="count" select="$count"/>
				<xsl:with-param name="level">top</xsl:with-param>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:apply-templates select="*[child::*]" mode="suburi"/>
		<xsl:apply-templates select="descendant::*[@rdf:about]" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="predicate">
		<xsl:param name="position"/>
		<xsl:param name="count"/>
		<xsl:param name="level"/>
		
		<xsl:variable name="line">	
			<xsl:if test="$level='bottom'">
				<xsl:value-of select="name()"/>
				<xsl:text> </xsl:text>
			</xsl:if>			
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:text>"</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<xsl:variable name="uri" select="@rdf:resource"/>
					<!--<xsl:choose>
						<xsl:when test="$namespaces//namespace[contains($uri, @uri)]">
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
							<xsl:text>&gt;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>&lt;</xsl:text>
							<xsl:value-of select="$uri"/>
							<xsl:text>&gt;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>-->

					<!-- apparently the object must be a URI without prefix -->
					<xsl:text>&lt;</xsl:text>
					<xsl:value-of select="$uri"/>
					<xsl:text>&gt;</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="string(.) and string(@xml:lang)">
				<xsl:value-of select="concat('@', @xml:lang)"/>
			</xsl:if>
			<xsl:if test="string(@rdf:datatype)">
				<xsl:variable name="uri" select="@rdf:datatype"/>
				<xsl:text>^^</xsl:text>
				<xsl:choose>
					<xsl:when test="$namespaces//namespace[contains($uri, @uri)]">
						<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>&lt;</xsl:text>
						<xsl:value-of select="$uri"/>
						<xsl:text>&gt;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="not(position()=last())">
					<xsl:choose>
						<xsl:when test="$level='top'">
							<xsl:text>, </xsl:text>
						</xsl:when>
						<xsl:when test="$level='bottom'">
							<xsl:text>;</xsl:text>
						</xsl:when>
					</xsl:choose>					
				</xsl:when>
				<xsl:when test="position()=last() and $position &lt; $count">
					<xsl:text>;</xsl:text>					
				</xsl:when>	
				<xsl:when test="position()=last() and $position = $count">
					<xsl:choose>
						<xsl:when test="parent::node()/*[child::*]">
							<xsl:text>;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$level='top'">
								<xsl:text>.</xsl:text>
							</xsl:if>							
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:when>				
			</xsl:choose>	
		</xsl:variable>
		<xsl:value-of select="concat(if (position() = 1) then ' ' else '&#x9;&#x9;', normalize-space($line), '&#xA;')"/>
	</xsl:template>
	
	<xsl:template match="*" mode="suburi">
		<xsl:variable name="chunk">
			<xsl:value-of select="name()"/>
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="string(child::*/@rdf:about)">
					<xsl:text>&lt;</xsl:text>
					<xsl:value-of select="child::*/@rdf:about"/>
					<xsl:text>&gt;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[ </xsl:text>
					<xsl:apply-templates select="child::*/*" mode="predicate">
						<xsl:with-param name="level">bottom</xsl:with-param>
					</xsl:apply-templates>
					<xsl:text> ]</xsl:text>					
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="not(position()=last())">
					<xsl:text>;</xsl:text>
				</xsl:when>
				<xsl:when test="position()=last() and count(parent::node()/descendant::*[@rdf:about]) &gt; 0">
					<xsl:text>.</xsl:text>
				</xsl:when>	
				<xsl:otherwise>.</xsl:otherwise>				
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('&#x9;', normalize-space($chunk), '&#xA;')"/>
	</xsl:template>
</xsl:stylesheet>
