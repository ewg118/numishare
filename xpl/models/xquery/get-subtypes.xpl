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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
					<xsl:variable name="pieces" select="tokenize(/exist-config/url, '/')"/>
					<xsl:variable name="xquery">
						<![CDATA[xquery version "1.0";
						declare namespace request="http://exist-db.org/xquery/request";
						declare namespace nuds="http://nomisma.org/nuds";
						declare namespace xlink="http://www.w3.org/1999/xlink";
						
						declare variable $identifiers as xs:string external;
						let $sequence:= tokenize($identifiers, '\|')
						return
						<response xmlns:xlink="http://www.w3.org/1999/xlink">
						{ for $id in $sequence return
						<type recordId="{$id}">
						{
						for $doc in collection('/db/numishare/objects/')[descendant::nuds:otherRecordId[@semantic='skos:broader']=$id]
						return <subtype recordId="{data($doc//nuds:recordId)}"><descMeta xmlns="http://nomisma.org/nuds"> { $doc//nuds:descMeta/* } </descMeta></subtype>
						}
						</type>
						}
						</response>]]>
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
							<xsl:value-of select="replace($xquery, 'numishare', $collection-name)"/>
						</query>
						<parameter>
							<name>identifiers</name>
							<value>
								<xsl:value-of select="$identifiers"/>
							</value>
						</parameter>
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
