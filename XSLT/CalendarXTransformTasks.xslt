<?xml version="1.0" encoding="iso-8859-1"?>


<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" xmlns:foo="http://www.foo.org" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:include href="functx-1.0-doc-2007-01.xsl"/>
	<xsl:include href="myFunctions.xsl"/>
	<xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="image/svg"/>
	
	
	
	<xsl:param name="packedView" select="xs:boolean('false')"/>
	
	
	
	<xsl:template match="/">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
			<defs packedView="{$packedView}">
				<rect id="APP" width="500" height="100" style="stroke: black; fill: lightgrey"/>
				<xsl:apply-templates select="events/event"/>
			</defs>
		</svg>
	</xsl:template>
	
	
	
	<xsl:template match="event">
		<xsl:variable name="scaleFactorX">
			<xsl:choose>
				<xsl:when test="$packedView or @intersecting=0">
					<xsl:value-of select="1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="1 div (@intersecting+1)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="scaleFactorY">
			<xsl:choose>
				<xsl:when test="$packedView">
					<xsl:value-of select="1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="foo:getScaleFactor(@startTime,@endTime)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<g id="T{@id}" xmlns="http://www.w3.org/2000/svg">
			<g transform="scale({$scaleFactorX},{$scaleFactorY})" xmlns="http://www.w3.org/2000/svg">
				<use xlink:href="#APP"/>
			</g>
			
			<xsl:call-template name="foo:printEventDescription">
				<xsl:with-param name="event">
					<xsl:value-of select="."/>
				</xsl:with-param>
			</xsl:call-template>
		</g>
	</xsl:template>
</xsl:stylesheet>
