<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last Modified: April 2021
	Function: evaluate the root node of the XML document and determine which pipeline to call (NUDS, NUDS Hoard, EpiDoc TEI) to serialize into HTML 
	for the fullscreen map page.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!--evaluate whether there are dcterms:isReplacedBy URIs and determine whether to implement HTTP 300 or 303 directs -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="url" select="/content/config/url"/>
				
				<xsl:template match="/">
					<xsl:choose>
						<!-- 303 -->
						<xsl:when
							test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) = 1 and descendant::*:control/*:maintenanceStatus='cancelledReplaced'">
							<xsl:variable name="uri">
								<xsl:choose>
									<xsl:when test="matches(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1], '^https?://')">
										<xsl:value-of select="descendant::*:otherRecordId[1]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, 'id/', descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<redirect bool="true">
								<uri>
									<xsl:value-of select="$uri"/>
								</uri>
							</redirect>
						</xsl:when>
						<!-- 300 -->
						<xsl:when
							test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) &gt; 1 and descendant::*:control/*:maintenanceStatus='cancelledSplit'">
							<xsl:variable name="uri">
								<xsl:choose>
									<xsl:when test="matches(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1], '^https?://')">
										<xsl:value-of select="descendant::*:otherRecordId[1]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url, 'id/', descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<redirect bool="true">
								<xsl:for-each select="descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']">
									<uri>
										<xsl:choose>
											<xsl:when test="matches(., '^https?://')">
												<xsl:value-of select="descendant::*:otherRecordId[1]"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat($url, 'id/', .)"/>
											</xsl:otherwise>
										</xsl:choose>
									</uri>
								</xsl:for-each>
							</redirect>
						</xsl:when>
						<xsl:otherwise>
							<redirect bool="false"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="redirect"/>
	</p:processor>

	<p:choose href="#redirect">
		<p:when test="redirect/@bool = true()">
			<!-- read the number of URIs to determine whether to implement HTTP 303 or 300 -->
			<p:choose href="#redirect">
				<p:when test="count(redirect/uri) = 1">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#redirect"/>
						<p:input name="config" href="../../../controllers/303-redirect.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../../controllers/300-multiple-choices.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<!-- call XPL based on namespace of document -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<recordType>
								<xsl:choose>
									<xsl:when test="*/namespace-uri()='http://nomisma.org/nudsHoard'">nudsHoard</xsl:when>
									<xsl:when test="*/namespace-uri()='http://nomisma.org/nuds'">nuds</xsl:when>
									<xsl:when test="*/namespace-uri()='http://www.tei-c.org/ns/1.0'">tei</xsl:when>
								</xsl:choose>
							</recordType>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="recordType"/>
			</p:processor>

			<p:choose href="#recordType">
				<p:when test="recordType='nudsHoard' or recordType = 'tei'">
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/object/html-map.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
					
					<p:processor name="oxf:html-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<version>5.0</version>
								<indent>true</indent>
								<content-type>text/html</content-type>
								<encoding>utf-8</encoding>
								<indent-amount>4</indent-amount>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="recordType='nuds'">
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="data" href="#data"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
								<xsl:template match="/">
									<recordType>
										<xsl:choose>
											<xsl:when test="*/@recordType='conceptual'">conceptual</xsl:when>
											<xsl:when test="*/@recordType='physical'">physical</xsl:when>
										</xsl:choose>
									</recordType>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="recordType"/>
					</p:processor>

					<p:choose href="#recordType">
						<!-- if it is a coin type record, then execute an ASK query for findspots, to determine whether timemap should display -->
						<p:when test="recordType='conceptual'">
							<p:processor name="oxf:pipeline">
								<p:input name="data" href="#config"/>
								<p:input name="config" href="../../../models/sparql/ask-findspots.xpl"/>
								<p:output name="data" id="hasFindspots"/>
							</p:processor>

							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hasFindspots" href="#hasFindspots"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html-map.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>

							<p:processor name="oxf:html-converter">
								<p:input name="data" href="#model"/>
								<p:input name="config">
									<config>
										<version>5.0</version>
										<indent>true</indent>
										<content-type>text/html</content-type>
										<encoding>utf-8</encoding>
										<indent-amount>4</indent-amount>
									</config>
								</p:input>
								<p:output name="data" ref="data"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/object/html-map.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>

							<p:processor name="oxf:html-converter">
								<p:input name="data" href="#model"/>
								<p:input name="config">
									<config>
										<version>5.0</version>
										<indent>true</indent>
										<content-type>text/html</content-type>
										<encoding>utf-8</encoding>
										<indent-amount>4</indent-amount>
									</config>
								</p:input>
								<p:output name="data" ref="data"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
			</p:choose>
		</p:otherwise>
	</p:choose>
</p:config>
