<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="content-type" select="//header[name[.='content-type']]/value"/>

					<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<head>
							<title>406 Not Acceptable</title>
						</head>
						<body>
							<h1>406 Not Acceptable</h1>
							<p><xsl:value-of select="$content-type"/> is not acceptable.</p>
						</body>
					</html>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="html"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="content-type" select="//header[name[.='content-type']]/value"/>
					<config>
						<status-code>406</status-code>
						<content-type>text/plain</content-type>
						<xsl:choose>
							<xsl:when test="string-length(substring-after(/request/request-url, 'id/')) &gt; 0">
								<header>
									<name>Accept</name>
									<value>text/html, application/xml, application/rdf+xml, text/turtle, application/vnd.google-earth.kml+xml, application/ld+json</value>
								</header>
							</xsl:when>							
							<xsl:otherwise>
								<header>
									<name>Accept</name>
									<value>text/html, application/atom+xml</value>
								</header>
							</xsl:otherwise>
						</xsl:choose>
						
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="header"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#html"/>
		<p:input name="config" href="#header"/>
	</p:processor>
</p:pipeline>
