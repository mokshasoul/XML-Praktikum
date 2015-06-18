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
	
	
	
	<xsl:param name="requestedDate" select="xs:date('2015-05-06')"/>
	
	<xsl:template match="/">
		<svg width="100%" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
			<defs>
				<g class="times" id="TIMES">
					<g transform="translate(0,140)">
						<text x="0" y="30" font-size="48">
					00:00
					<tspan x="0" y="130">02:00</tspan>
							<tspan x="0" y="250">04:00</tspan>
							<tspan x="0" y="370">06:00</tspan>
							<tspan x="0" y="490">08:00</tspan>
							<tspan x="0" y="610">10:00</tspan>
							<tspan x="0" y="730">12:00</tspan>
							<tspan x="0" y="850">14:00</tspan>
							<tspan x="0" y="970">16:00</tspan>
							<tspan x="0" y="1090">18:00</tspan>
							<tspan x="0" y="1210">20:00</tspan>
							<tspan x="0" y="1330">22:00</tspan>
						</text>
					</g>
				</g>
				<xsl:for-each-group select="events/event" group-by="@date">
					<g id="T{@date}">
						<xsl:call-template name="foo:printDayAndDate">
							<xsl:with-param name="date" select="@date"/>
						</xsl:call-template>
						<g transform="translate(10,120)">
						
						
						<!--			
							Applies Template for event
						-->
							<xsl:apply-templates select="current-group()"/>
						</g>
					</g>
				</xsl:for-each-group>
			</defs>
			<g transform="scale(0.4,0.4)">
				<use xlink:href="#TIMES"/>
				<g transform="translate(120,0)">
				<xsl:call-template name="foo:printDayAndDate">
							<xsl:with-param name="date" select="$requestedDate"/>
				</xsl:call-template>
				<use xlink:href="#T{$requestedDate}"/>
				</g>
			</g>
		</svg>
	</xsl:template>
	
	
	
	<xsl:template match="event">
		<xsl:variable name="startTime" select="@startTime"/>
		<xsl:variable name="endTime" select="@endTime"/>
		
		
		<g transform="translate(0,{foo:getTimeInMinutes($startTime)})" xmlns="http://www.w3.org/2000/svg">
			<use xlink:href="CalendarXTransformTasks.xml#T{@id}" transform="scale(0.96,{foo:getScaleFactor($startTime,$endTime)})"/>
		</g>
	</xsl:template>
</xsl:stylesheet>
