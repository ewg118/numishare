<?xml version="1.0" encoding="UTF-8"?>

<!-- Author: Ethan Gruber
        Last modified: July 2018
        Function: process XML response from the numishareResults nomisma.org API into a block of associated images and hoard/object count -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">

    <!-- ************** PROCESS GROUP OF SPARQL RESULTS FROM NOMISMA TO DISPLAY IMAGES ************** -->
    <xsl:template match="group" mode="results">
        <xsl:variable name="hoard-count" select="number(hoard-count)"/>
        <xsl:variable name="object-count" select="number(object-count)"/>
        <xsl:variable name="count" select="$hoard-count + $object-count"/>
        <!-- display images -->
        <xsl:apply-templates select="descendant::object" mode="results"/>
        <!-- object count -->
        <xsl:if test="$count &gt; 0">
            <br/>
            <xsl:if test="$object-count &gt; 0">
                <xsl:choose>
                    <xsl:when test="$object-count = 1">object</xsl:when>
                    <xsl:otherwise>objects</xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$object-count"/>
                <xsl:if test="$hoard-count &gt; 0">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>

            <xsl:if test="$hoard-count &gt; 0">
                <xsl:choose>
                    <xsl:when test="$hoard-count = 1">
                        <xsl:value-of select="numishare:normalizeLabel('results_hoard', $lang)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="numishare:normalizeLabel('results_hoards', $lang)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$hoard-count"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="object" mode="results">
        <xsl:variable name="position" select="position()"/>
        <!-- obverse -->
        <xsl:choose>
            <xsl:when test="string(obvRef) and string(obvThumb)">
                <a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{obvThumb}" class="side-thumbnail"/>
                </a>
            </xsl:when>
            <xsl:when test="not(string(obvRef)) and string(obvThumb)">
                <img src="{obvThumb}" class="side-thumbnail">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                </img>
            </xsl:when>
            <xsl:when test="string(obvRef) and not(string(obvThumb))">
                <a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{obvRef}" class="side-thumbnail"/>
                </a>
            </xsl:when>
        </xsl:choose>
        <!-- reverse-->
        <xsl:choose>
            <xsl:when test="string(revRef) and string(revThumb)">
                <a class="thumbImage" rel="gallery" href="{revRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{revThumb}" class="side-thumbnail"/>
                </a>
            </xsl:when>
            <xsl:when test="not(string(revRef)) and string(revThumb)">
                <img src="{revThumb}" class="side-thumbnail">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                </img>
            </xsl:when>
            <xsl:when test="string(revRef) and not(string(revThumb))">
                <a class="thumbImage" rel="gallery" href="{revRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{revRef}" class="side-thumbnail"/>
                </a>
            </xsl:when>
        </xsl:choose>
        <!-- combined -->
        <xsl:choose>
            <xsl:when test="string(comRef) and string(comThumb)">
                <a class="thumbImage" rel="gallery" href="{comRef}" title="Image of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{comThumb}" class="combined-thumbnail"/>
                </a>
            </xsl:when>
            <xsl:when test="not(string(comRef)) and string(comThumb)">
                <img src="{comThumb}" class="combined-thumbnail">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                </img>
            </xsl:when>
            <xsl:when test="string(comRef) and not(string(comThumb))">
                <a class="thumbImage" rel="gallery" href="{comRef}" title="Image of {@identifier}: {@collection}" id="{@uri}">
                    <xsl:if test="$position &gt; 1">
                        <xsl:attribute name="style">display:none</xsl:attribute>
                    </xsl:if>
                    <img src="{comRef}" class="combined-thumbnail"/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
