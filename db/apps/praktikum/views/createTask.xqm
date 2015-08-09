xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $data-path := '/db/apps/praktikum/data/'
let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
let $post-req := request:get-data()

let $description := $post-req//description
let $endDate := $post-req//endDate
let $startDate := $post-req//startDate
let $startTime := $post-req//startTime
let $endTime := $post-req//endTime
let $attendees := $post-req//attendees
let $location := $post-req//location

let $dbCal := doc('/db/apps/praktikum/data/calendarX2.xml')
let $event :=  if ($post-req) then(
<superEvent description="{$description}">
            <eventRules>
                <eventRule description="{$description}" startTime="{$startTime}" endTime="{$endTime}" note="">
                    <attendees>
                        <attendee></attendee>
                    </attendees>
                    <location>{$location}</location>
                </eventRule>
            </eventRules>
        </superEvent>
)else( <root/>)

let $pattern := if (not($event = "failure")) then 
    <dailyPattern description="{$description}" startDate="{$startDate}" endDate="{if($endDate) then ($endDate) else ($startDate)}" />
    else (<empty/>)
let $store-return-status := if ($post-req) then (update insert $event into $dbCal//SuperEvents) else ()
let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
    <head>
        <link href="screen.css" rel="stylesheet" type="text/css"/>
        <xf:model id="appendData">
            <xf:instance id="dataI" src="../data/data.xml">
                <data>
                    <description/>
                    <category/>
                    <startDate/>
                    <endDate/>
                    <startTime/>
                    <endTime/>
                    <note/>
                    <attendees>
                        <attendee/>
                    </attendees>
                    <location/>
                </data>
            </xf:instance>
            <xf:bind ref="description" required="false()"/>
            <xf:bind ref="startDate" required="true()" type="xs:date"/>
            <xf:bind ref="endDate" required="true()" type="xs:date" />
            <xf:bind ref="startTime" required="false()" type="xs:string"/>
            <xf:bind ref="endTime" required="false()" type="xs:string"/>
            <xf:bind ref="attendees" required="false()"/>
            <xf:bind ref="location" required="false()"/>

            <xf:submission id="convert" method="post" replace="none" action="../edit/addEvents.xqm">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message>An Error has occured please contact Admin</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>Task Created You Can Close The Window Now or Create New Task</xf:message>
                    <xf:reset model="appendData"/>
                </xf:action>
            </xf:submission>
        </xf:model>
        <title/>
    </head>
    <body>
         <div id="wrapper">
         <div id="wrapperPropper">
        <h1>Create New Task</h1>
        <div id="navBar">
            <ul>
                <li>
                    <a href="getViews.xqm">Home</a>
                </li>
            </ul>
        </div>
    
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
                <xf:input ref="instance('dataI')//attendee">
                    <xf:label  class="inputLabels">Attendee:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//location">
                    <xf:label  class="inputLabels">Location:</xf:label>
                </xf:input>
            </xf:group>
            <xf:submit submission="convert">
                <xf:label>Create New Task</xf:label>
            </xf:submit>
            </div>
            </div>
        </div>
    </body>
</html>)
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
let $debug := processing-instruction xsltforms-options {'debug="yes"'}    
return
  ($xslt-pi,$form)