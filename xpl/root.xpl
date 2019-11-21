<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'collections-list.xml')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<!-- attempt to load the collections-list XML file from eXist. If it does not exist, then it has not been created (first run) -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" id="url-data"/>
	</p:processor>

	<!-- catch exception -->
	<p:processor name="oxf:exception-catcher">
		<p:input name="data" href="#url-data"/>
		<p:output name="data" id="url-data-checked"/>
	</p:processor>

	<!-- Check whether we had an exception -->
	<p:choose href="#url-data-checked">
		<p:when test="/exceptions">
			<!-- Extract the message -->
			<p:processor name="oxf:xslt">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config">
					<html xsl:version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<head>
							<title>Numishare</title>
							<meta name="viewport" content="width=device-width, initial-scale=1"/>
							<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
							<!-- bootstrap -->
							<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
							<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
							<meta http-equiv="refresh" content="10;URL=admin/"/>
						</head>
						<body>
							<div class="container-fluid">
								<div class="row">
									<div class="col-md-12">
										<h2>Numishare</h2>
										<p>
											<xsl:value-of select="/exceptions/exception/message"/>
										</p>
										<p>The collections-list.xml file does not appear in the eXist-db collection, presumably becaues this is the first time you have run Numishare. Be sure to create
											the 'numishare-admin' Tomcat role following the <a href="https://github.com/ewg118/numishare/wiki/Tomcat-Authentication" target="_blank">instructions</a> on
											Github. This page will automatically redirect to the admin panel in 10 seconds. If it does not, click <a href="admin/">here</a>.</p>
									</div>
								</div>
							</div>
						</body>
					</html>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config" href="../ui/xslt/root.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
