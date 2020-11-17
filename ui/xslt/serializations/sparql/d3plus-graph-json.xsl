<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: November 2020
	Function: serialized aggregated SPARQL response for die linking into the JSON model required to render in the d3plus Network graph -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>

	<xsl:variable name="linkCount"
		select="
			if (count(//res:sparql[1]//res:result) &gt; count(//res:sparql[2]//res:result)) then
				count(//res:sparql[1]//res:result)
			else
				count(//res:sparql[2]//res:result)"
		as="xs:integer"/>
	<xsl:variable name="specimenCount" select="sum(//res:binding[@name = 'count']/res:literal)"/>

	<xsl:template match="/">

		<xsl:variable name="model" as="element()*">
			<_object>
				<nodes>
					<_array>
						<xsl:apply-templates
							select="descendant::res:binding[@name = 'die']/res:uri | descendant::res:binding[@name = 'altDie']/res:uri | descendant::res:binding[@name = 'type']/res:uri"
							mode="nodes"/>
					</_array>
				</nodes>
				<edges>
					<_array>
						<xsl:apply-templates select="descendant::res:result" mode="edges"/>
					</_array>
				</edges>
			</_object>
		</xsl:variable>

		<!--<xsl:copy-of select="$model"/>-->
		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="*" mode="nodes">
		<xsl:variable name="uri" select="."/>
		<xsl:variable name="name" select="parent::res:binding/@name"/>

		<xsl:if test="not(preceding::node()[. = $uri])">
			<_object>
				<id>
					<xsl:value-of select="tokenize(., '/')[last()]"/>
				</id>
				<uri>
					<xsl:value-of select="."/>
				</uri>
				<label datatype="xs:string">
					<xsl:value-of select="ancestor::res:result/res:binding[@name = concat($name, 'Label')]/res:literal"/>
				</label>
				<side>
					<xsl:choose>
						<xsl:when test="parent::res:binding[@name = 'type']">type</xsl:when>
						<xsl:otherwise>
							<!-- evaluate the side by means of the variable and whether it's in the first or second SPARQL response (only one response for types) -->
							<xsl:choose>
								<xsl:when test="//res:binding[@name = 'die'][res:uri = $uri]">
									<xsl:choose>
										<xsl:when
											test="
												//res:sparql[1]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]
												and //res:sparql[2]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]"
											>both</xsl:when>
										<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]">obv</xsl:when>
										<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]">rev</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="//res:binding[@name = 'altDie'][res:uri = $uri]">
									<xsl:choose>
										<xsl:when
											test="
												//res:sparql[1]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]
												and //res:sparql[2]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]"
											>both</xsl:when>
										<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]">rev</xsl:when>
										<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]">obv</xsl:when>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</side>
			</_object>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:result" mode="edges">
		<xsl:variable name="uri" select="res:uri"/>

		<_object>
			<source>
				<xsl:apply-templates select="res:binding[@name = 'die']" mode="edges"/>
			</source>
			<target>
				<xsl:apply-templates select="res:binding[@name = 'altDie']" mode="edges"/>
			</target>
			<xsl:if test="res:binding[@name = 'count']">
				<count>
					<xsl:value-of select="res:binding[@name = 'count']/res:literal"/>
				</count>
			</xsl:if>
			<weight>
				<xsl:call-template name="numishare:networkWeight"/>
			</weight>
		</_object>

		<xsl:if test="res:binding[@name = 'type']">
			<_object>
				<source>
					<xsl:apply-templates select="res:binding[@name = 'type']" mode="edges"/>
				</source>
				<target>
					<xsl:apply-templates select="res:binding[@name = 'die']" mode="edges"/>
				</target>
				<weight>
					<xsl:call-template name="numishare:networkWeight"/>
				</weight>
			</_object>
		</xsl:if>

	</xsl:template>

	<xsl:template match="res:binding[@name = 'altDie' or @name = 'die' or @name = 'type']" mode="edges">
		<xsl:value-of select="tokenize(res:uri, '/')[last()]"/>
	</xsl:template>

	<xsl:template name="numishare:networkWeight">
		<xsl:choose>
			<!-- determine the line weight for links related to coin types -->
			<xsl:when test="res:binding[@name = 'count']">

				<xsl:variable name="count" select="res:binding[@name = 'count']/res:literal" as="xs:integer"/>

				<!-- determine the maximimum pixel size -->
				<xsl:variable name="max" select="round($specimenCount div $linkCount)"/>
				<!-- determine the weight as a percentage of the total number of specimens multipled by maximum size -->
				<xsl:variable name="weight" select="($count div $specimenCount) * $max"/>

				<xsl:choose>
					<!-- adjust the weight so that the smallest value is 1 -->
					<xsl:when test="$weight &lt; 1">
						<!-- find the 1/x multiplier for the smallest count that would increase it to a minimum digit of 1 -->
						<xsl:variable name="multiplier"
							select="min(//res:binding[@name = 'count']/res:literal) div ((min(//res:binding[@name = 'count']/res:literal) div $specimenCount) * $max)"/>

						<xsl:value-of select="round($multiplier * $weight)"/>
					</xsl:when>
					<!-- adjust weight down to a max displayable of 24 -->
					<xsl:when test="$weight &gt; 24">
						<xsl:value-of select="round($weight)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="round($weight)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>4</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
