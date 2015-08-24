xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';

import module namespace functx = 'http://www.functx.com' at 'functx-1.0-doc-2007-01.xq';
import module namespace helper = 'http://www.help.com' at 'helperFunctions.xqm';

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $post-req := request:get-data()
let $login := if (not($post-req)) then xmldb:login($collection, 'admin', '') else ()



let $today := adjust-date-to-timezone(fn:current-date(), ())
let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
let $svg :=  (
                  (:POST parameters   :)

   let $param1 := if($post-req) then $post-req//mode else 'Day'
   let $param2 := if($post-req) then xs:date($post-req//date) else $today
   let $packedView := if ($post-req) then (if ($param1 eq 'Month') then 'true' else $post-req//packedView) else 'false'
    
   let $param := <parameters><param name='requestedDate' value='{$param2}' /><param name='packedView' value='{$packedView}' /><param name='mode' value='{$param1}'/></parameters>        
   (: XSLT Transform Parameter :)   
   let $xsl := doc("/db/apps/praktikum/views/CalendarXTransform.xslt")
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
   
   (: Generate SVG :)
   let $svg-file := 'CalendarXTransform.xml'
   let $svg-xsl := doc('/db/apps/praktikum/views/CalendarXTransform.xslt')
   let $svg-generation := transform:transform($event-input,$svg-xsl,$param)
   let $store-return-status := xmldb:store($data-path,$svg-file,$svg-generation)

   return
        transform:transform($event-input,$xsl,$param)
)
let $param2 := if ($post-req) then xs:date($post-req//date) else $today
let $param1 := if ($post-req) then $post-req//mode else 'Day'
let $param3 := if ($post-req) then $post-req//packedView else 'false'
let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:my="test" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <head>
  <link rel="stylesheet" href="screen.css" media="all" type="text/css"/>
        <xf:model id="viewModel">
            <xf:instance xmlns="" id="dateData">
                <root>
                    <date>{$param2}</date>
                    <mode></mode>
                    <packedView>{$param3}</packedView>
                </root>
            </xf:instance >
            <xf:submission id="getView" method="post" action="getViews.xqm"/>
            <xf:bind nodeset="instance('dateData')//date" type="xs:date"/>
            <xf:bind nodeset="instance('dateData')//mode" type="xs:string"/>
            <xf:bind nodeset="instance('dateData')//packedView" type="xs:boolean"/>
        </xf:model>
        <title>CalendarX</title>
    </head>
    <body>
        <div id="wrapper">
        <div id="wrapperPropper">
            <h1 id="title"> CalendarX System </h1>
            <div id="views">
                <xf:group id="selectionView" model="viewModel">
                    <xf:input id="date" ref="instance('dateData')//date">
                        <xf:label>Enter a date: </xf:label>
                    </xf:input>
                    <xf:trigger>
                        <xf:label>Day View</xf:label>
                        <xf:action  ev:event="DOMActivate">
                            <xf:setvalue ref="instance('dateData')//mode">Day</xf:setvalue>
                            <xf:setvalue ref="instance('dateData')//packedView">{data($param3)}</xf:setvalue>
                            <xf:send  submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Week View</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:setvalue ref="instance('dateData')//mode">Week</xf:setvalue>
                            <xf:setvalue ref="instance('dateData')//packedView">{data($param3)}</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Month View</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:setvalue ref="instance('dateData')//mode">Month</xf:setvalue>
                            <xf:setvalue ref="instance('dateData')//packedView">{data($param3)}</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    {if($param1 eq 'Day' or $param1 eq 'Week') then (
                    <xf:select1 id="packedView" ref="instance('dateData')//packedView" appearance="minimal" incremental="true">  
            <xf:label>View: </xf:label>
                <xf:item>
                    <xf:label>Standard</xf:label>
                    <xf:value>false</xf:value> 
                </xf:item>
                <xf:item>
                    <xf:label>List</xf:label>
                    <xf:value>true</xf:value>
                </xf:item>
                <xf:action ev:event="xforms-value-changed">
                            <xf:setvalue ref="instance('dateData')//mode">{data($param1)}</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                		
          </xf:select1>) else ()}
                </xf:group>
                    <xf:trigger id="taskButton">
                        <xf:label>Create Task</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:load show="replace" resource="createTask.xqm"/>
                        </xf:action>
                    </xf:trigger>
            </div>
<div id="calendarView">
                <h1>{switch($param1) 
                    case 'Day' return format-date($param2, "[D1o] [MNn] [Y]", "en", (), ()) 
                    case 'Week' return concat('Week of ', format-date(helper:getMondayOfWeek($param2), "[D].[M].[Y]"))
                    case 'Month' return format-date($param2, "[MNn] [Y]", "en", (), ())
                    default return ''
                }</h1>  
                <div id="calendarViewSVG">
               {$svg}
               </div>
            </div>
            </div>
        </div>
    </body>
</html>
)

let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
let $debug := processing-instruction xsltforms-options {'debug="yes"'}    
return
  ($xslt-pi,$form)
