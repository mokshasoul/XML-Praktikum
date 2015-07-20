<?xml version="1.0" encoding="UTF-8" ?>


<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" 
xmlns:foo="http://www.foo.org"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:functx="http://www.functx.com" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">


	<xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="image/svg"/>
	<xsl:include href="functx-1.0-doc-2007-01.xsl"/>
	<xsl:include href="myFunctions.xsl"/>
	
	
	<xsl:param name="requestedDate" select="xs:date('2015-05-07')"/>
	
<xsl:param name="packedView" select="xs:boolean('true')" />
	
	
	
	<xsl:template match="/">
		
		
		<svg width="1472px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
			<defs>
			
			<!--
			This builds the week for all distinct mondays, i.e. all weeks where at least one event is in
			 -->
				<xsl:for-each select="distinct-values(events/event/@mondayOfWeek)">
					<xsl:call-template name="foo:printWeekOfDay">
						<xsl:with-param name="date" select="."/>
					</xsl:call-template>
				</xsl:for-each>
				
			<!--
			This builds the week of the requested day (but only if it is necessary, i.e. only if the week has no event (otherwise it has already been generated)).
			 -->
				<xsl:if test="not(contains(distinct-values(events/event/@mondayOfWeek), foo:getCertainDayOfWeek($requestedDate, 0)))">
					<xsl:call-template name="foo:printWeekOfDay">
						<xsl:with-param name="date" select="$requestedDate"/>
					</xsl:call-template>
				</xsl:if>
			</defs>
			<g transform="scale(0.35,0.35)">
				<xsl:if test="not($packedView)"><use xlink:href="CalendarXTransformDay.xml#TIMES" transform="translate(0,15)"/>
</xsl:if>
				
				
				<!--
				Print the requested week (first, get the monday to get the id of the week)
	 			-->
				<use xlink:href="#WEEKOF{foo:getCertainDayOfWeek($requestedDate, 0)}" transform="translate(120,0)"/>
			</g>
		</svg>
	</xsl:template>
</xsl:stylesheet>
