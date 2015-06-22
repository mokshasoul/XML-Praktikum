<?xml version="1.0" encoding="UTF-8" ?>

<!-- New document created with EditiX at Thu Jun 11 08:54:02 CEST 2015 -->

<xsl:stylesheet version="2.0" exclude-result-prefixes="xs functx" 
xmlns:foo="http://www.foo.org"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:functx="http://www.functx.com" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">



	<xsl:output method="xml" indent="yes"/>
	
	
	
	
	
	<!--	
returns the number of minutes between 00:00 and the given time-->
	
<xsl:function name="foo:getTimeInMinutes">
		<xsl:param name="time"/>
		<xsl:value-of select="fn:minutes-from-time(xs:time($time))+fn:hours-from-time(xs:time($time))*60"/>
	</xsl:function>
    
  	  
<!--	
returns the number of minutes between two times of a day-->
    
	<xsl:function name="foo:getLengthOfEvent">
		<xsl:param name="startTime"/>
		<xsl:param name="endTime"/>
		<xsl:value-of select="foo:getTimeInMinutes($endTime)-foo:getTimeInMinutes($startTime)"/>
	</xsl:function>
	
		
<!--	
returns the scaling factor for scaling the event box accoridng to the duratio of the event-->
	    
	<xsl:function name="foo:getScaleFactor">
		<xsl:param name="startTime"/>
		<xsl:param name="endTime"/>
		<xsl:value-of select="foo:getLengthOfEvent($startTime,$endTime)*0.01"/>
	</xsl:function>
	
	
	
	<xsl:template name="foo:printVerticalLine" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
		<g id="VLINE">
			<g transform="translate(-2,0)">
			<line x1="0" y1="0" x2="0" y2="1540" style="stroke:#7125FE;stroke-width:4"/>
			</g>
		</g>
	</xsl:template>
	
	<xsl:template name="foo:printOverlay" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
		<rect id="overlayX" width="500" height="130" style="fill:#BEBECB"/>
	</xsl:template>
	
	<xsl:template name="foo:printHorizontalLine" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
		<g id="HLINE">
			<line x1="0" y1="0" x2="3500" y2="0" style="stroke:#7125FE;stroke-width:4"/>
		</g>
	</xsl:template>
	
	
	
	<!--
		This is a day template for days without any events.
	 -->
	<xsl:template name="foo:printDayAndDate" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
		<xsl:param name="date"/>
		<g transform="translate(0,0) scale(1,12)">
			<xsl:call-template name="foo:printOverlay"/>
		</g>
		<text x="170" y="80" font-size="100" fill="#7125FE" fill-opacity="0.8">
			<xsl:value-of select="functx:day-of-week-abbrev-en(  xs:date($date))"/>
		</text>
		<text x="170" y="120" font-size="40" fill="#ffffff" fill-opacity="0.8">
			<xsl:value-of select="$date"/>
		</text>
	</xsl:template>
	
	
	<!--
	Get a certain day of the week in which "date" is. The requested day of the week can be 0=monday, 1=tuesday and so on
	-->
	<xsl:function name="foo:getCertainDayOfWeek">
		<xsl:param name="date"/>
		<xsl:param name="day"/><!-- Monday=0, Tuesday=1,... -->
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
	
	
		<!-- 
			Prints the whole week in which a certain day lies.
		 -->
	<xsl:template name="foo:printWeekOfDay" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
		<xsl:param name="date"/>
		<xsl:variable name="mondayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 0)"/>
		</xsl:variable>
		<xsl:variable name="tuesdayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 1)"/>
		</xsl:variable>
		<xsl:variable name="wednesdayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 2)"/>
		</xsl:variable>
		<xsl:variable name="thursdayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 3)"/>
		</xsl:variable>
		<xsl:variable name="fridayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 4)"/>
		</xsl:variable>
		<xsl:variable name="saturdayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 5)"/>
		</xsl:variable>
		<xsl:variable name="sundayOfWeek">
			<xsl:value-of select="foo:getCertainDayOfWeek($date, 6)"/>
		</xsl:variable>
		
		
		
		<!--
			The week is always identified by the date of the monday of that week
	 	-->
		<g id="WEEKOF{$mondayOfWeek}">
			<g transform="translate(20,0)">
				<xsl:call-template name="foo:printDayAndDate">
					<xsl:with-param name="date" select="$mondayOfWeek"/>
				</xsl:call-template>
				<use xlink:href="CalendarXTransformDay.xml#T{$mondayOfWeek}"/>
				<xsl:call-template name="foo:printVerticalLine"/>
				<g transform="translate(504,0)">
					<xsl:call-template name="foo:printDayAndDate">
						<xsl:with-param name="date" select="$tuesdayOfWeek"/>
					</xsl:call-template>
					<use xlink:href="CalendarXTransformDay.xml#T{$tuesdayOfWeek}"/>
					<xsl:call-template name="foo:printVerticalLine"/>
					<g transform="translate(504,0)">
						<xsl:call-template name="foo:printDayAndDate">
							<xsl:with-param name="date" select="$wednesdayOfWeek"/>
						</xsl:call-template>
						<use xlink:href="CalendarXTransformDay.xml#T{$wednesdayOfWeek}"/>
						<xsl:call-template name="foo:printVerticalLine"/>
						<g transform="translate(504,0)">
							<xsl:call-template name="foo:printDayAndDate">
								<xsl:with-param name="date" select="$thursdayOfWeek"/>
							</xsl:call-template>
							<use xlink:href="CalendarXTransformDay.xml#T{$thursdayOfWeek}"/>
							<xsl:call-template name="foo:printVerticalLine"/>
							<g transform="translate(504,0)">
								<xsl:call-template name="foo:printDayAndDate">
									<xsl:with-param name="date" select="$fridayOfWeek"/>
								</xsl:call-template>
								<use xlink:href="CalendarXTransformDay.xml#T{$fridayOfWeek}"/>
								<xsl:call-template name="foo:printVerticalLine"/>
								<g transform="translate(504,0)">
									<xsl:call-template name="foo:printDayAndDate">
										<xsl:with-param name="date" select="$saturdayOfWeek"/>
									</xsl:call-template>
									<use xlink:href="CalendarXTransformDay.xml#T{$saturdayOfWeek}"/>
									<xsl:call-template name="foo:printVerticalLine"/>
									<g transform="translate(504,0)">
										<xsl:call-template name="foo:printDayAndDate">
											<xsl:with-param name="date" select="$sundayOfWeek"/>
										</xsl:call-template>
										<use xlink:href="CalendarXTransformDay.xml#T{$sundayOfWeek}"/>
										<xsl:call-template name="foo:printVerticalLine"/>
										<g transform="translate(504,0)">
											<xsl:call-template name="foo:printVerticalLine"/>
										</g>
									</g>
								</g>
							</g>
						</g>
					</g>
				</g>
			</g>
		</g>
	</xsl:template>
</xsl:stylesheet>