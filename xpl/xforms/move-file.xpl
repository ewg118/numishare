<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="generator-config"/>
	<p:param type="input" name="serializer-config"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" id="media"/>
	</p:processor>
	
	<p:processor name="oxf:file-serializer">
		<p:input name="data" href="#media"/>
		<p:input name="config" href="#serializer-config"/>		
	</p:processor>
	
	<!-- used only to return dummy content -->
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#generator-config"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>

