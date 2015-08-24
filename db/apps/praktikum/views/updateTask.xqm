xquery version "3.0";
(: IN CASE WE WANT TO ADD WEEKS 
                     {if ($weeklyTest) then
                                            <repeatDayOfWeek />
                                            else()}
  {if ($weeklyTest) then 
                 <xf:bind ref="repeatDayOfWeek" required="false()" type="xs:boolean" />
             else()
             }    
                  {
               if ($weeklyTest) then 
                               <xf:select ref="repeatDayOfWeek" appearance="full">
                    <xf:item>
                           <xf:label>Monday</xf:label>
                           <xf:value>monday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Tuesday</xf:label>
                           <xf:value>tuesday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Wednesday</xf:label>
                           <xf:value>wednesday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Thursday</xf:label>
                           <xf:value>thursday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Friday</xf:label>
                           <xf:value>friday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Saturday</xf:label>
                           <xf:value>saturday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Sunday</xf:label>
                           <xf:value>sunday</xf:value>
                    </xf:item>
                </xf:select>  
                else
                ()
               }
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
import module namespace fn = "http://www.functx.com" at 'functx-1.0-doc-2007-01.xq';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";


let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $data-path := '/db/apps/praktikum/data/'
let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')

let $eventDescription := request:get-parameter('description','')
let $eventDate := request:get-parameter('date','')


let $dbEvents := doc('/db/apps/praktikum/data/simpleEvents.xml')
let $dbCal := doc('/db/apps/praktikum/data/sampleCalendarX.xml')
let $event := $dbEvents//event[@description=$eventDescription][@date=$eventDate]
let $location := xs:string($event/location/@description)
let $note := xs:string($dbCal//superEvent[@description=$eventDescription]//eventRule[1]/@note)
let $startTime := xs:string($dbCal//superEvent[@description=$eventDescription]//eventRule[1]/@startTime)
let $endTime := xs:string($dbCal//superEvent[@description=$eventDescription]//eventRule[1]/@endTime)
let $attendees := $dbCal//superEvent[@description=$eventDescription]//eventRule[1]/attendees
let $pattern := $dbCal//superEvent[@description=$eventDescription]//eventRule[1]/recurrencePattern
let $dailyTest := $dbCal//patterns/dailyPattern[@description=$eventDescription]
let $weeklyTest := if ($dbCal//patterns/unionPattern[@description=concat($eventDescription,'_1')]) then
    $dbCal//patterns/unionPattern[@description=concat($eventDescription,'_1')]
    else
    $dbCal//patterns/weeklyPattern[@description=$eventDescription]
    
let $endDate := if ($dailyTest )then
                 xs:string($dbCal//dailyPattern[@description=$eventDescription]/@endDate)        
                else
                ( 
                let $patternLookup := $dbCal//patterns/*[@description=xs:string($pattern)]
                let $patternName := xs:string($patternLookup/firstPattern)
                return
                    xs:string($dbCal//dailyPattern[@description=$patternName]/@endDate)
                )
let $startDateSeries := if($dailyTest) then
                   xs:string($dbCal//dailyPattern[@description=$eventDescription]/@startDate)
                   else(
                   xs:boolean('false')
                )
let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
    <head>
        <link href="screen.css" rel="stylesheet" type="text/css"/>
        <xf:model id="appendData">
            <xf:instance xmlns="" id="dataI">
                <root>
                    <description>{$eventDescription}</description>
                    <startDate>{xs:date(if ($startDateSeries) then $startDateSeries else $eventDate)}</startDate>
                    <endDate>{xs:date(if ($endDate) then $endDate else $eventDate)}</endDate>
                    <startTime>{$startTime}</startTime>
                    <endTime>{$endTime}</endTime>
                    <note>{$note}</note>
                    <origDescription>{$eventDescription}</origDescription>
                    <attendees>
                        {
                               for $attendee at $pos in $attendees/*
                            return
                  
                               if (not($pos = 1)) then concat(', ',fn:trim(xs:string($attendee))) else(
              
                                fn:trim(xs:string($attendee))
                                )
                              
                        }
                    </attendees>
                    <location>{$location}</location>
                    <series>{xs:boolean('false')}</series>

                    </root>
            </xf:instance>
            <xf:bind ref="description" required="false()" type="xs:string"/>
            <xf:bind ref="startDate" required="false()" type="xs:date" readonly="true()"/>
            <xf:bind ref="endDate" required="false()" type="xs:date"  readonly="true()"/>
            <xf:bind ref="startTime" required="false()" type="xs:string"/>
            <xf:bind ref="endTime" required="false()" type="xs:string"/>
            <xf:bind ref="attendees" required="false()"/>
            <xf:bind ref="location" required="false()"/>
            <xf:bind ref="series" required="false()" type="xs:boolean"/>
           
           <xf:submission id="convert" method="post" replace="none" action="../edit/updateEvents.xqm">
           <xf:action ev:event="xforms-submit-error">
                    <xf:message>An Error has occured please contact Admin</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>Task Updated You Can Close The Window Now</xf:message>
                    <xf:reset model="appendData"/>
                </xf:action>
            </xf:submission>
        </xf:model>
        <title>Update Task</title>
    </head>
    <body>
         <div id="wrapper">
         <div id="wrapperPropper">
            <h1 id="title">Update Task</h1>
       <div id="views"><a href="getViews.xqm">Home</a></div>
    
        <div id="inputBlock">
            <xf:group model="appendData" appearance="bf:verticalTable">
                <xf:input ref="instance('dataI')//description">
                    <xf:label class="inputLabels">Task Name:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//category">
                    <xf:label  class="inputLabels">Task Category:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//startDate">
                    <xf:label  class="inputLabels">Start Date:</xf:label>
                </xf:input>
               <xf:input ref="instance('dataI')//endDate">
                    <xf:label class="inputLabels">End Date:</xf:label>
               </xf:input>
                <xf:input ref="instance('dataI')//startTime">
                    <xf:label  class="inputLabels">Start Time:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//endTime">
                    <xf:label  class="inputLabels">End Time:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//note">
                    <xf:label  class="inputLabels">Additional Comments:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//attendees">
                    <xf:label  class="inputLabels">Attendee:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//location">
                    <xf:label  class="inputLabels">Location:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//series">
                    <xf:label class="inputLabels">Edit Only Occurence?</xf:label>
                    <xf:action
                       if="instance('dataI')//series">
                             <xf:setvalue ref="instance('dataI')//startDate" value="{$eventDate}" />
                    </xf:action>
                    <xf:action

                       if="not(instance('dataI')//series)">
                             <xf:setvalue ref="instance('dataI')//startDate" value="{$startDateSeries}" /></xf:action>
               </xf:input>
          
            </xf:group> 
            <xf:submit submission="convert">
                <xf:label>Update Task</xf:label>
            </xf:submit>
            </div>
            </div>
        </div>
    </body>
</html>)

let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
return
   ($xslt-pi,$form) 