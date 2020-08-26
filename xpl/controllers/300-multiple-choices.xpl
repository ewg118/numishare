<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: August 2020
	Function: Serialize the NUDS or NUDS-Hoard document into an HTML page with multiple choices for cancelledSplit entities with a proper
	HTTP 300 Multiple Choices header -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:saxon="http://saxon.sf.net/">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../ui/xslt/controllers/300-multiple-choices.xsl"/>
		<p:output name="data" id="html"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#html"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output name="html" encoding="UTF-8" method="html" indent="no" omit-xml-declaration="yes"/>

				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						content-type="text/html">
						<xsl:value-of select="saxon:serialize(/html, 'html')"/>
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<status-code>300</status-code>
						<content-type>text/html</content-type>

						<header>
							<name>Link</name>
							<value>
								<xsl:for-each select="descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']">									
									<xsl:value-of select="concat('&lt;', ., '&gt;; rel=&#x022;latest-version&#x022;')"/>
									<xsl:if test="not(position() = last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</value>
						</header>
						
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="serializer-config"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#serializer-config"/>
	</p:processor>
</p:pipeline>
