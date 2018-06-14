<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="configuration"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:file">
		<p:input name="config" href="#configuration"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#configuration"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>

