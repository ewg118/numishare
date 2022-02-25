<!--
    Copyright (C) 2007 Orbeon, Inc.

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param name="dump" type="input"/>
	<p:param name="data" type="output"/>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="oxf:/apps/numishare/exist-config.xml"/>
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
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<config>
								<role>numishare-admin</role>								
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="request-security-config"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<config>
								<role>numishare-admin</role>
								<xsl:for-each select="//collection">
									<role>
										<xsl:value-of select="@role"/>
									</role>
								</xsl:for-each>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="request-security-config"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	<p:processor xmlns:xforms="http://www.w3.org/2002/xforms" name="oxf:request-security">
		<p:input name="config" href="#request-security-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
