<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: December 2019
	Function: Serialize the XQuery results for symbols and combine with the total number of symbol documents in order
		to serialize an HTML page for the symbols 
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
		<p:input name="config" href="../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- execute the XQuery for the simple count for the symbols collection -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/xquery/symbol-count.xpl"/>
		<p:output name="data" id="count"/>
	</p:processor>
	
	<!-- get the distinct letters that appear in the collection -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/xquery/get-symbol-letters.xpl"/>
		<p:output name="data" id="letters"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="count" href="#count"/>
		<p:input name="letters" href="#letters"/>
		<p:input name="data" href="aggregate('content', #config, #data)"/>		
		<p:input name="config" href="../../../ui/xslt/pages/symbols.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
