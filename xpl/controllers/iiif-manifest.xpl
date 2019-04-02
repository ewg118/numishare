<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	Numishare
	Apache License 2.0
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">
    <p:param type="input" name="data"/>
    <p:param type="output" name="data"/>
    
    <p:processor name="oxf:pipeline">
        <p:input name="config" href="../models/config.xpl"/>		
        <p:output name="data" id="config"/>
    </p:processor>
    
    <p:processor name="oxf:unsafe-xslt">		
        <p:input name="data" href="aggregate('content', #data, #config)"/>
        <p:input name="config">
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:variable name="url" select="/content/config/url"/>
                
                <xsl:template match="/">
                    <xsl:choose>
                        <xsl:when test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) = 1 and descendant::*:control/*:maintenanceStatus='cancelledReplaced'">
                            <xsl:variable name="uri">
                                <xsl:choose>
                                    <xsl:when test="matches(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1], '^https?://')">
                                        <xsl:value-of select="descendant::*:otherRecordId[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($url, 'id/', descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1])"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <redirect uri="{$uri}/manifest">true</redirect>
                        </xsl:when>
                        <xsl:otherwise>
                            <redirect>false</redirect>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
            </xsl:stylesheet>
        </p:input>
        <p:output name="data" id="redirect"/>
    </p:processor>
    
    <!-- evaluate whether there should be a 303 redirect for replaced concepts -->
    <p:choose href="#redirect">
        <p:when test="redirect='true'">
            <p:processor name="oxf:pipeline">
                <p:input name="data" href="#redirect"/>
                <p:input name="config" href="303-redirect.xpl"/>		
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:when>
        <p:otherwise>
            <!-- call XPL based on namespace of document -->
            <p:processor name="oxf:unsafe-xslt">
                <p:input name="data" href="#data"/>
                <p:input name="config">
                    <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                        <xsl:template match="/">
                            <recordType>
                                <xsl:choose>
                                    <xsl:when test="*/namespace-uri()='http://nomisma.org/nudsHoard'">nudsHoard</xsl:when>
                                    <xsl:when test="*/namespace-uri()='http://nomisma.org/nuds'">nuds</xsl:when>
                                </xsl:choose>
                            </recordType>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:input>
                <p:output name="data" id="recordType"/>
            </p:processor>
            
            <p:choose href="#recordType">
                <p:when test="recordType='nudsHoard'">
                    <p:processor name="oxf:identity">
                        <p:input name="data">
                            <response>Not valid for IIIF</response>
                        </p:input>
                        <p:output name="data" ref="data"/>
                    </p:processor>
                </p:when>
                <p:when test="recordType='nuds'">
                    <p:processor name="oxf:pipeline">
                        <p:input name="data" href="#data"/>
                        <p:input name="config" href="../views/serializations/nuds/iiif-manifest.xpl"/>
                        <p:output name="data" ref="data"/>
                    </p:processor>
                </p:when>		
            </p:choose>
        </p:otherwise>
    </p:choose>
</p:config>
