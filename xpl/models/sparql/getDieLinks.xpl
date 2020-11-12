<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: November 2020
	Function: Execute a SPARQL query in order to query the die links given a die URI or type URI, given the 'die' or 'type' HTTP
	request parameter. 
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
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:template match="/">
					<collection_type>
						<xsl:value-of select="/config/collection_type"/>
					</collection_type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="collection_type"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:template match="/">
					<namedGraph>
						<xsl:value-of select="/request/parameters/parameter[name='namedGraph']/value"/>
					</namedGraph>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="namedGraph"/>
	</p:processor>
	
	<p:choose href="#collection_type">
		<p:when test="collection_type = 'cointype'">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="request" href="#request"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side">
					<side/>
				</p:input>
				<p:input name="config" href="query-die-relations.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="collection_type = 'die'">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="request" href="#request"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side">
					<side>obv</side>
				</p:input>
				<p:input name="config" href="query-die-relations.xpl"/>
				<p:output name="data" id="obv-dies"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="request" href="#request"/>
				<p:input name="namedGraph" href="#namedGraph"/>
				<p:input name="side">
					<side>rev</side>
				</p:input>
				<p:input name="config" href="query-die-relations.xpl"/>
				<p:output name="data" id="rev-dies"/>
			</p:processor>
			
			<p:processor name="oxf:identity">
				<p:input name="data" href="aggregate('dies', #obv-dies, #rev-dies)"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
	</p:choose>
	
</p:config>
