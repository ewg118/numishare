<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last Modified: January 2020
	Function: Execute an XQuery to to aggregate all symbol RDF files for the RDF export.	
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

	<!-- get XQuery from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/xquery/aggregate-symbols.xquery</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="query-document"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="xquery" href="#query-document"/>
		<p:input name="data" href="oxf:/apps/numishare/exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					<xsl:variable name="pieces" select="tokenize(/exist-config/url, '/')"/>					
					<xsl:variable name="xquery" select="doc('input:xquery')"/>
					
					<config>
						<vendor>exist</vendor>
						<property>
							<name>serverName</name>
							<value>
								<xsl:value-of select="substring-before($pieces[3], ':')"/>
							</value>
						</property>
						<property>
							<name>port</name>
							<value>
								<xsl:value-of select="substring-after($pieces[3], ':')"/>
							</value>
						</property>
						<property>
							<name>user</name>
							<value>
								<xsl:value-of select="/exist-config/username"/>
							</value>
						</property>
						<property>
							<name>password</name>
							<value>
								<xsl:value-of select="/exist-config/password"/>
							</value>
						</property>
						<query>
							<xsl:value-of select="replace($xquery, 'numishare', $collection-name)"/>
						</query>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="xquery-config"/>
	</p:processor>

	<p:processor name="oxf:xquery">
		<p:input name="config" href="#xquery-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
