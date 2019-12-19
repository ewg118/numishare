<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last Modified: December 2019
	Function: Execute an XQuery to generate pages for symbols in the local Numishare instance.	
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


	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:param name="page" select="doc('input:request')/request/parameters/parameter[name='page']/value"/>
					
					<xsl:variable name="limit">24</xsl:variable>
					<xsl:variable name="offset">
						<xsl:choose>
							<xsl:when test="string-length($page) &gt; 0 and $page castable as xs:integer and number($page) > 0">
								<xsl:value-of select="(($page - 1) * number($limit)) + 1"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					<xsl:variable name="pieces" select="tokenize(/exist-config/url, '/')"/>
					
					<xsl:variable name="xquery">
						<![CDATA[xquery version "1.0";
						declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
						declare namespace skos="http://www.w3.org/2004/02/skos/core#";
						declare namespace crm="http://www.cidoc-crm.org/cidoc-crm/";
						declare namespace crmdig="http://www.ics.forth.gr/isl/CRMdig";
						
						<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
					xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
					xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:void="http://rdfs.org/ns/void#"
					xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
					xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig"> { 
							for $record in subsequence(collection('/db/numishare/symbols'), OFFSET, LIMIT)
								return 
									$record//rdf:RDF/*[1]
							}
						</rdf:RDF>]]>
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
							<xsl:value-of select="replace(replace(replace($xquery, 'numishare', $collection-name), 'OFFSET', $offset), 'LIMIT', $limit)"/>
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
