xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=html media-type=text/xml indent=yes";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $post-req := request:get-data()

let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
let $svg :=  if($post-req) then(
               (:POST parameters:)

                let $param1 := $post-req//mode
                let $param2 := xs:date($post-req//date)
                 let $param := <parameters><param name="packedView" value="false"/><param name="requestedDate" value="{$param2}" /></parameters>        
               (: XSLT Transform Parameter :)   
               let $xsl := doc(concat("/db/apps/praktikum/views/CalendarXTransform",$param1,".xslt"))
               let $xq := if ($param1="Day")
                        then getEvents:getEventsForDay($param2)
                        else if ($param1="Week")
                        then getEvents:getEventsForWeek($param2) 
                        else getEvents:getEventsForMonth($param2) 
                              
                   (: Generate Event File
                      Set it as input:)
 let $data-path := '/db/apps/praktikum/data/'
let $events-file := 'simpleEvents.xml'
let $store-return-status := xmldb:store($data-path, $events-file, $xq)
let $event-input := doc('/db/apps/praktikum/data/simpleEvents.xml')

(: Generate Task SVG :)
let $tasks-file := 'CalendarXTransformTasks.xml'
let $tasks-xsl := doc('/db/apps/praktikum/views/CalendarXTransformTasks.xslt')
let $tasks-generation := transform:transform($event-input,$tasks-xsl,$param)
let $store-return-status := xmldb:store($data-path,$tasks-file,$tasks-generation)
(: Generate Day SVG :)
let $days-file := 'CalendarXTransformDay.xml'
let $days-xsl := doc('/db/apps/praktikum/views/CalendarXTransformDay.xslt')
let $days-generation := transform:transform($event-input,$days-xsl,$param)
let $store-return-status := xmldb:store($data-path,$days-file,$days-generation)
(: Generate Weeks SVG :)
let $weeks-file := 'CalendarXTransformWeek.xml'
let $weeks-xsl := doc('/db/apps/praktikum/views/CalendarXTransformWeek.xslt')
let $weeks-generation := transform:transform($event-input,$weeks-xsl,$param)
let $store-return-status := xmldb:store($data-path,$weeks-file,$weeks-generation)
(: Generate Month :)
let $month-file := 'CalendarXTransformMonth.xml'
let $month-xsl := doc('/db/apps/praktikum/views/CalendarXTransformMonth.xslt')

return
    transform:transform( $event-input, $xsl, $param)
)else(

)

let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:my="test" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <head>
  <link rel="stylesheet" href="screen.css" media="all" type="text/css"/>
        <xf:model id="viewModel">
            <xf:instance xmlns="" id="dateData">
                <root>
                    <date/>
                    <mode/>
                </root>
            </xf:instance>
            <xf:instance id='inlinesvg'>
            <svg />
            </xf:instance>

            <xf:submission id="getView" method="post" action="getViews.xqm"/>
            <xf:bind nodeset="instance('dateData')//date" type="xs:date"/>
            <xf:bind nodeset="instance('dateData')//mode" type="xs:string"/>
        </xf:model>
        <title>Calendar Forms </title>
    </head>
    <body>
        <div id="wrapper">
            <h1 id="title"> Calendar System </h1>

            <div id="views">
                <xf:group id="selectionView" model="viewModel">
                    <xf:input id="date" ref="instance('dateData')//date">
                        <xf:label>Enter a date: </xf:label>
                    </xf:input>
                    <br/>
                    <xf:trigger>
                        <xf:label>Day View</xf:label>
                        <xf:action  ev:event="DOMActivate">
                            <xf:setvalue ref="instance('dateData')//mode">Day</xf:setvalue>
                            <xf:send  submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Week View</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:setvalue ref="instance('dateData')//mode">Week</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:submit>
                        <xf:label>Month View</xf:label>
                    </xf:submit>
                </xf:group>
                    <xf:trigger id="taskButton">
                        <xf:label>Create Task</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:load show="replace" resource="createTask.xhtml"/>
                        </xf:action>
                    </xf:trigger>
            </div>


<div id="calendarView">
               
               {$svg}

            </div>
        </div>
    </body>
</html>
)
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
       
return

  ($xslt-pi,$form)