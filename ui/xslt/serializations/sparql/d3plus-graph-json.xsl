<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: June 2021
	Function: serialized aggregated SPARQL response for die and symbol linking into the JSON model required to render in the d3plus Network graph -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../json/json-metamodel.xsl"/>

	<xsl:param name="api" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>
	<xsl:param name="rootURI" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
	
	<xsl:template match="/">

		<xsl:variable name="model" as="element()*">
			<_object>
				<nodes>
					<_array>
						<xsl:apply-templates
							select="
								descendant::res:binding[@name = 'die']/res:uri | descendant::res:binding[@name = 'altDie']/res:uri | descendant::res:binding[@name = 'type']/res:uri |
								descendant::res:binding[@name = 'symbol']/res:uri | descendant::res:binding[@name = 'altSymbol']/res:uri"
							mode="nodes"/>
					</_array>
				</nodes>
				<edges>
					<_array>
						<xsl:choose>
							<xsl:when test="$api = 'getDieLinks'">
								<xsl:variable name="linkCount"
									select="
									if (count(//res:sparql[1]//res:result) &gt; count(//res:sparql[2]//res:result)) then
									count(//res:sparql[1]//res:result)
									else
									count(//res:sparql[2]//res:result)"
									as="xs:integer"/>
								<xsl:variable name="specimenCount" select="sum(//res:binding[@name = 'count']/res:literal)"/>	
								<xsl:variable name="minCount" select="min(//res:binding[@name = 'count']/res:literal)"/>
								
								<xsl:apply-templates select="descendant::res:result" mode="die-edges">
									<xsl:with-param name="linkCount" select="$linkCount"/>
									<xsl:with-param name="specimenCount" select="$specimenCount"/>
									<xsl:with-param name="minCount" select="$minCount"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="$api = 'getSymbolLinks'">
								
								<!-- generate a unique list of edges -->
								<xsl:variable name="edges" as="node()*">
									<edges xmlns="http://www.w3.org/2005/sparql-results#">
										<xsl:for-each select="descendant::res:result">
											<xsl:variable name="source" select="res:binding[@name = 'symbol']/res:uri"/>
											<xsl:variable name="target" select="res:binding[@name = 'altSymbol']/res:uri"/>
											
											<xsl:if test="not(preceding::res:result[res:binding[@name = 'altSymbol']/res:uri = $source and res:binding[@name = 'symbol']/res:uri = $target])">
												<xsl:copy-of select="."/>
											</xsl:if>
											
										</xsl:for-each>
									</edges>
								</xsl:variable>								
								
								<xsl:variable name="linkCount" select="count($edges//res:result)"/>
								<xsl:variable name="specimenCount" select="sum($edges//res:binding[@name = 'count']/res:literal)"/>		
								<xsl:variable name="minCount" select="min($edges//res:binding[@name = 'count']/res:literal)"/>
								
								<xsl:apply-templates select="$edges/descendant::res:result" mode="symbol-edges">
									<xsl:with-param name="linkCount" select="$linkCount"/>
									<xsl:with-param name="specimenCount" select="$specimenCount"/>									
									<xsl:with-param name="minCount" select="$minCount"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
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
				<xsl:if test="ancestor::res:result/res:binding[@name = concat($name, 'Image')]">
					<image>
						<xsl:value-of select="tokenize(ancestor::res:result/res:binding[@name = concat($name, 'Image')]/res:literal, '\|')[last()]"/>
					</image>
				</xsl:if>
				<side>
					<xsl:choose>
						<xsl:when test="parent::res:binding[@name = 'type']">type</xsl:when>
						<xsl:otherwise>
							<!-- evaluate the side by means of the variable and whether it's in the first or second SPARQL response (only one response for types) -->
							<xsl:choose>
								<xsl:when test="$api = 'getDieLinks'">
									<xsl:choose>
										<xsl:when test="//res:binding[@name = 'die'][res:uri = $uri]">
											<xsl:choose>
												<xsl:when
													test="
														//res:sparql[1]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]
														and //res:sparql[2]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]"
													>both</xsl:when>
												<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]"
													>obv</xsl:when>
												<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name = 'die'][res:uri = $uri]"
													>rev</xsl:when>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="//res:binding[@name = 'altDie'][res:uri = $uri]">
											<xsl:choose>
												<xsl:when
													test="
														//res:sparql[1]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]
														and //res:sparql[2]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]"
													>both</xsl:when>
												<xsl:when test="//res:sparql[1]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]"
													>rev</xsl:when>
												<xsl:when test="//res:sparql[2]/res:results/res:result/res:binding[@name = 'altDie'][res:uri = $uri]"
													>obv</xsl:when>
											</xsl:choose>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="$api = 'getSymbolLinks'">
									<xsl:choose>
										<xsl:when test="$uri = $rootURI">root</xsl:when>		
										<xsl:when test="ancestor::res:result/res:binding[@name = 'symbol']/res:uri = $rootURI">first</xsl:when>
										<xsl:otherwise>second</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</side>
			</_object>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:result" mode="die-edges">
		<xsl:param name="linkCount"/>
		<xsl:param name="specimenCount"/>
		<xsl:param name="minCount"/>

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
				<xsl:call-template name="numishare:networkWeight">
					<xsl:with-param name="linkCount" select="$linkCount"/>
					<xsl:with-param name="specimenCount" select="$specimenCount"/>
					<xsl:with-param name="minCount" select="$minCount"/>
				</xsl:call-template>
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
					<xsl:call-template name="numishare:networkWeight">
						<xsl:with-param name="linkCount" select="$linkCount"/>
						<xsl:with-param name="specimenCount" select="$specimenCount"/>						
						<xsl:with-param name="minCount" select="$minCount"/>
					</xsl:call-template>
				</weight>
			</_object>
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="res:result" mode="symbol-edges">
		<xsl:param name="linkCount"/>
		<xsl:param name="specimenCount"/>
		<xsl:param name="minCount"/>
		
		<_object>
			<source>
				<xsl:apply-templates select="res:binding[@name = 'symbol']" mode="edges"/>
			</source>
			<target>
				<xsl:apply-templates select="res:binding[@name = 'altSymbol']" mode="edges"/>
			</target>
			<count>
				<xsl:value-of select="res:binding[@name = 'count']/res:literal"/>
			</count>	
			<weight>
				<xsl:call-template name="numishare:networkWeight">
					<xsl:with-param name="linkCount" select="$linkCount"/>
					<xsl:with-param name="specimenCount" select="$specimenCount"/>					
					<xsl:with-param name="minCount" select="$minCount"/>
				</xsl:call-template>
			</weight>			
		</_object>
		
		
	</xsl:template>

	<xsl:template match="res:binding[@name = 'altDie' or @name = 'die' or @name = 'type' or @name = 'symbol' or @name = 'altSymbol']" mode="edges">
		<xsl:value-of select="tokenize(res:uri, '/')[last()]"/>
	</xsl:template>

	<xsl:template name="numishare:networkWeight">
		<xsl:param name="linkCount"/>
		<xsl:param name="specimenCount"/>
		<xsl:param name="minCount"/>
		
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
							select="$minCount div (($minCount div $specimenCount) * $max)"/>

						<xsl:value-of select="round($multiplier * $weight)"/>
					</xsl:when>
					<!-- adjust weight down to a max displayable of 24 -->
					<xsl:when test="$weight &gt; 24">24</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="round($weight)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>4</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
