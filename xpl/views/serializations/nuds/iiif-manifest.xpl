<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	Numishare
	Apache License 2.0
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
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
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="recordType='conceptual'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/iiif-type-examples.xpl"/>
				<p:output name="data" id="sparqlResults"/>
			</p:processor>

			<!-- iterate through the SPARQL results and request the info.json for each IIIF service -->
			<p:for-each href="#sparqlResults" select="//res:binding[contains(@name, 'Service')]" root="images" id="images">

				<!-- generate an XForms processor to request JSON -->
				<p:processor name="oxf:xslt">
					<p:input name="data" href="current()"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
							xmlns:res="http://www.w3.org/2005/sparql-results#">
							<xsl:variable name="service" select="concat(descendant::res:uri, '/info.json')"/>

							<xsl:template match="/">
								<xforms:submission method="get" action="{$service}">
									<xforms:header>
										<xforms:name>User-Agent</xforms:name>
										<xforms:value>XForms/Numishare</xforms:value>
									</xforms:header>
								</xforms:submission>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="xforms-config"/>
				</p:processor>

				<p:processor name="oxf:xforms-submission">
					<p:input name="request" href="#request"/>
					<p:input name="submission" href="#xforms-config"/>
					<p:output name="response" id="json"/>
				</p:processor>

				<!-- wrap the JSON response into an XML element so that the URI can be passed through; the URI in the JSON may be escaped, whereas the URI stored in SPARQL may not be -->
				<p:processor name="oxf:xslt">
					<p:input name="data" href="current()"/>
					<p:input name="json" href="#json"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
							xmlns:res="http://www.w3.org/2005/sparql-results#">
							<xsl:template match="/">
								<image uri="{descendant::res:uri}">
									<xsl:copy-of select="doc('input:json')"/>
								</image>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" ref="images"/>
				</p:processor>
			</p:for-each>

			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="sparqlResults" href="#sparqlResults"/>
				<p:input name="images" href="#images"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/nuds/iiif-manifest.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- only render a result if there is a IIIF service -->
			<p:choose href="#data">
				<p:when
					test="descendant::mets:fileGrp[@USE='obverse']/mets:file[@USE='iiif'] or descendant::mets:fileGrp[@USE='reverse']/mets:file[@USE='iiif']">
					<!-- read IIIF services for info.json to extract height and width -->
					<!--obverse -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="data" href="#data"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
								<xsl:variable name="service"
									select="concat(descendant::mets:fileGrp[@USE='obverse']/mets:file[@USE='iiif']/mets:FLocat/@xlink:href, '/info.json')"/>

								<xsl:template match="/">
									<xforms:submission method="get" action="{$service}">
										<xforms:header>
											<xforms:name>User-Agent</xforms:name>
											<xforms:value>XForms/Numishare</xforms:value>
										</xforms:header>
									</xforms:submission>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="obverse-xforms-config"/>
					</p:processor>

					<p:processor name="oxf:xforms-submission">
						<p:input name="request" href="#request"/>
						<p:input name="submission" href="#obverse-xforms-config"/>
						<p:output name="response" id="obverse-json"/>
					</p:processor>

					<!-- reverse -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="data" href="#data"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
								<xsl:variable name="service"
									select="concat(descendant::mets:fileGrp[@USE='reverse']/mets:file[@USE='iiif']/mets:FLocat/@xlink:href, '/info.json')"/>

								<xsl:template match="/">
									<xforms:submission method="get" action="{$service}">
										<xforms:header>
											<xforms:name>User-Agent</xforms:name>
											<xforms:value>XForms/Numishare</xforms:value>
										</xforms:header>
									</xforms:submission>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="reverse-xforms-config"/>
					</p:processor>

					<p:processor name="oxf:xforms-submission">
						<p:input name="request" href="#request"/>
						<p:input name="submission" href="#reverse-xforms-config"/>
						<p:output name="response" id="reverse-json"/>
					</p:processor>

					<!-- serialize into JSON -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="obverse-json" href="#obverse-json"/>
						<p:input name="reverse-json" href="#reverse-json"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/iiif-manifest.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<!-- multiple cards -->
				<p:when test="descendant::mets:fileGrp[@USE='card']/descendant::mets:file[@USE='iiif']">
					
					<!-- aggregate the info.json for every IIIF service -->
					<p:for-each href="#data" select="descendant::mets:file[@USE='iiif']" root="images" id="iiif-json">
						
						<p:processor name="oxf:unsafe-xslt">
							<p:input name="data" href="current()"/>
							<p:input name="config">
								<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
									xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
									<xsl:variable name="service" select="concat(//mets:FLocat/@xlink:href, '/info.json')"/>
									
									<xsl:template match="/">
										<xforms:submission method="get" action="{$service}">
											<xforms:header>
												<xforms:name>User-Agent</xforms:name>
												<xforms:value>XForms/Numishare</xforms:value>
											</xforms:header>
										</xforms:submission>
									</xsl:template>
								</xsl:stylesheet>
							</p:input>
							<p:output name="data" id="xforms-config"/>
						</p:processor>
						
						<p:processor name="oxf:xforms-submission">
							<p:input name="request" href="#request"/>
							<p:input name="submission" href="#xforms-config"/>
							<p:output name="response" ref="iiif-json"/>
						</p:processor>
					</p:for-each>

					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="iiif-json" href="#iiif-json"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/iiif-manifest.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="data" href="#data"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
								<xsl:template match="/">
									<xsl:text>{"error":"No IIIF services"}</xsl:text>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
