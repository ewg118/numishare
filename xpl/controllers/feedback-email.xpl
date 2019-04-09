<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	 Date last modified: April 2019
	 Function: passes content from the feedback form and contact information from a Numishare config to the email processor to send email(s) to relevant persons -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:email">
		<p:input name="data" href="#data"/>
	</p:processor>
	
</p:pipeline>
