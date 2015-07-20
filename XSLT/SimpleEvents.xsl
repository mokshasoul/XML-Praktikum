<?xml version="1.0" encoding="iso-8859-1"?>


<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" 
xmlns:foo="http://www.foo.org"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:functx="http://www.functx.com" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">


<xsl:output method="xml" indent="yes" standalone="no" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" media-type="text/xml"/>


	<xsl:include href="functx-1.0-doc-2007-01.xsl"/>



<xsl:function name="foo:getCertainDayOfWeek">
	<xsl:param name="date"/>
	<xsl:param name="day"/>  <!-- Monday=0, Tuesday=1,... -->
	<xsl:variable name="dayOfWeekOfRequestedDate"><!-- Monday=0, Tuesday=1,... -->
		<xsl:choose>
			<xsl:when test="functx:day-of-week($date)=0">P6D</xsl:when>
			<xsl:otherwise>P<xsl:value-of select="functx:day-of-week($date)-1"/>D</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="differenceToMonday">
		<xsl:value-of select="xs:dayTimeDuration($dayOfWeekOfRequestedDate)"/>
	</xsl:variable>
	<xsl:variable name="mondayOfWeek">
		<xsl:value-of select="xs:date($date) - xs:dayTimeDuration($differenceToMonday)"/>
	</xsl:variable>

	<xsl:variable name="tuesdayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P1D')"/>
				</xsl:variable>
				<xsl:variable name="wednesdayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P2D')"/>
				</xsl:variable>
				<xsl:variable name="thursdayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P3D')"/>
				</xsl:variable>
				<xsl:variable name="fridayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P4D')"/>
				</xsl:variable>
				<xsl:variable name="saturdayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P5D')"/>
				</xsl:variable>
				<xsl:variable name="sundayOfWeek">
					<xsl:value-of select="xs:date($mondayOfWeek)+ xs:dayTimeDuration('P6D')"/>
				</xsl:variable>
	<xsl:choose>
	<xsl:when test="$day=0">
		<xsl:value-of select="$mondayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=1">
		<xsl:value-of select="$tuesdayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=2">
		<xsl:value-of select="$wednesdayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=3">
		<xsl:value-of select="$thursdayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=4">
		<xsl:value-of select="$fridayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=5">
		<xsl:value-of select="$saturdayOfWeek"/>
	</xsl:when>
	<xsl:when test="$day=6">
		<xsl:value-of select="$sundayOfWeek"/>
	</xsl:when>
	</xsl:choose>
	
</xsl:function>





<xsl:template match="/">
  <xsl:variable name="numberOfEventsPerDate">
	<xsl:for-each-group select="events/event" group-by="@date">
		<day date="{@date}">
			<xsl:copy-of select="count(current-group())">
			</xsl:copy-of>
		</day>
	</xsl:for-each-group>
	</xsl:variable>
	
	
	<xsl:variable name="height">
<!--		130 (header)+20(bottom)-->
		<xsl:value-of select="150+(max($numberOfEventsPerDate/day))*100"/>
	</xsl:variable>
  

  <events  height="{$height}">
<xsl:apply-templates select="events/event"/>
</events>
</xsl:template>






  <xsl:template match="event">

    <xsl:variable name="StartTime" select="@startTime"/>
    <xsl:variable name="EndTime" select="@endTime"/>

    <xsl:variable name="normalizedStartTime" select="fn:replace(@startTime, ':', '')"/>
    <xsl:variable name="normalizedEndTime" select="fn:replace(@endTime, ':', '')"/>

    <event id="{@date}_{$normalizedStartTime}_{$normalizedEndTime}" description="{@description}" date="{@date}"
  mondayOfWeek="{foo:getCertainDayOfWeek(@date,0)}"
		startTime="{@startTime}" endTime="{@endTime}">
		<location description="{location/@description}"/>
</event>


</xsl:template>


</xsl:stylesheet>
