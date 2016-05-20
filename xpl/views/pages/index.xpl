<?xml version="1.0" encoding="UTF-8"?>
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

	<!--<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>-->

	<!-- get feature, if enabled -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/solr/get_feature.xpl"/>
		<p:output name="data" id="feature-model"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#feature-model"/>
		<p:input name="config" href="../../views/ajax/get_feature.xpl"/>
		<p:output name="data" id="feature-view"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #feature-view)"/>
		<p:input name="config" href="../../../ui/xslt/pages/index.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>

	<!-- construct the HTTP header depending on availability of languages -->
	<!--<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/config">
					<config>
						<status-code>200</status-code>
						<content-type>text/plain</content-type>
						<xsl:choose>
							<xsl:when test="count(descendant::language[@enabled='true']) &gt; 1">
								<xsl:for-each select="descendant::language[@enabled='true']">
									<header>
										<name>Accept-Language</name>
										<value>
											<xsl:value-of select="@code"/>
										</value>
									</header>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<header>
									<name>Accept-Language</name>
									<value>en</value>
								</header>
							</xsl:otherwise>
						</xsl:choose>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="header"/>
	</p:processor>-->

	<!--<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#html"/>
		<p:input name="config" href="#header"/>		
	</p:processor>-->
</p:config>
