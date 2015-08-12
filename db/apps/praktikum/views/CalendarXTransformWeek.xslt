<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foo="http://www.foo.org" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0" exclude-result-prefixes="xs functx">
    <xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="image/svg"/>
    <xsl:include href="functx-1.0-doc-2007-01.xsl"/>
    <xsl:include href="myFunctions.xsl"/>
    <xsl:param name="requestedDate"/>
    <xsl:param name="packedView"/>
    <xsl:template match="/">
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
            <g transform="scale(0.35,0.35)">
                <xsl:if test="$packedView eq 'true'">
                    <use xlink:href="../data/CalendarXTransformDay.xml#TIMES" transform="translate(0,15)"/>
                </xsl:if>
                
                
               <!-- print the requested week -->
                <g transform="translate(120,0)">
                    <xsl:call-template name="foo:printWeekOfDay">
                        <xsl:with-param name="date" select="$requestedDate"/>
                    </xsl:call-template>
                </g>
            </g>
        </svg>
    </xsl:template>
</xsl:stylesheet>