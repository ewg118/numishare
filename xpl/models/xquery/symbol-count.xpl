<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last Modified: June 2020
	Function: Execute an XQuery to generate pages for symbols in the local Numishare instance. A union catalog site joins collections
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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="exist-config" href="oxf:/apps/numishare/exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:param name="symbol" select="doc('input:request')/request/parameters/parameter[name='symbol']"/>
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					<xsl:variable name="pieces" select="tokenize(doc('input:exist-config')/exist-config/url, '/')"/>

					<xsl:variable name="xquery">
						<![CDATA[xquery version "1.0"; 
						declare namespace crm = "http://www.cidoc-crm.org/cidoc-crm/";
						declare namespace crmdig = "http://www.ics.forth.gr/isl/CRMdig/";
						declare namespace nmo = "http://nomisma.org/ontology#";
						declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
						<count>
							{
							count(collection(COLLECTION)XPATH)
							}
						</count>]]>
					</xsl:variable>
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
								<xsl:value-of select="doc('input:exist-config')/exist-config/username"/>
							</value>
						</property>
						<property>
							<name>password</name>
							<value>
								<xsl:value-of select="doc('input:exist-config')/exist-config/password"/>
							</value>
						</property>
						<query>
							<xsl:variable name="collection">
								<xsl:choose>
									<xsl:when test="/config/union_type_catalog/@enabled = true()">
										<xsl:for-each select="/config/union_type_catalog/series/@collectionName">
											<xsl:value-of select="concat('&#x022;/db/', ., '/symbols&#x022;')"/>
											<xsl:if test="not(position() = last())">
												<xsl:text>, </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
										
										<xsl:value-of select="concat('&#x022;/db/', $collection-name, '/symbols&#x022;')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:choose>
								<xsl:when test="count($symbol//value) &gt; 0">
									<xsl:variable name="xpath">
										<xsl:text>[</xsl:text>
										<!-- only display monograms with images (eliminates supertypes) -->
										<xsl:text>descendant::crm:P165i_is_incorporated_in[@rdf:resource or child::crmdig:D1_Digital_Object] and </xsl:text>			
										<xsl:for-each select="$symbol//value">
											<xsl:value-of select="concat('(descendant::crm:P106_is_composed_of = &#x022;', ., '&#x022; or descendant::crm:P165i_is_incorporated_in = &#x022;', ., '&#x022;)')"/>
											<xsl:if test="not(position() = last())">
												<xsl:text> and </xsl:text>
											</xsl:if>
										</xsl:for-each>
										<xsl:text>]</xsl:text>
									</xsl:variable>

									<xsl:value-of select="replace(replace($xquery, 'COLLECTION', $collection), 'XPATH', $xpath)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="xpath">[descendant::crm:P165i_is_incorporated_in[@rdf:resource or child::crmdig:D1_Digital_Object]]</xsl:variable>
									<xsl:value-of select="replace(replace($xquery, 'COLLECTION', $collection), 'XPATH', $xpath)"/>
								</xsl:otherwise>
							</xsl:choose>
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
