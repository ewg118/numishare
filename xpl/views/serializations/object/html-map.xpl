<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="url" select="/content/config/url"/>

				<xsl:template match="/">
					<xsl:choose>
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

							<redirect uri="{$uri}">true</redirect>
						</xsl:when>
						<xsl:otherwise>
							<redirect>false</redirect>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="redirect"/>
	</p:processor>

	<p:choose href="#redirect">
		<p:when test="redirect='true'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#redirect"/>
				<p:input name="config" href="../../../controllers/303-redirect.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
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
								</xsl:choose>
							</recordType>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="recordType"/>
			</p:processor>

			<p:choose href="#recordType">
				<p:when test="recordType='nudsHoard'">
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
