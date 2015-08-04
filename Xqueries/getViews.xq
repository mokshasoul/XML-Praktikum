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
               let $param2 := $post-req//date
               (: XSLT Transform Parameter :)
               let $param := <parameters><param name="requestedDate" value="{$param2}" /></parameters>
               let $xsl := doc(concat("/db/apps/praktikum/CalendarXTransform",$param1,".xslt"))
               let $xq := if ($param1="Day")
                        then  getEvents:getEventsForDay($param2) 
                        else if ($param1="Week")
                        then getEvents:getEventsForWeek($param2) 
                        else getEvents:getEventsForMonth($param2) 
                              
                   (: Generate Event File
                      Set it as input:)
                        let $events-file := 'simpleEvents.xml'
                        let $store-return-status := xmldb:store($collection, $events-file, $xq)
                        let $input := doc('/db/apps/praktikum/simpleEvents.xml')
                        (: Generate Task SVG :)
                        let $tasks-file := 'CalendarXTransformTasks.xml'
                        let $tasks-input := doc('/db/apps/praktikum/simpleEvents.xml')
                        let $tasks-xsl := doc('/db/apps/praktikum/CalendarXTransformTasks.xslt')
                        let $tasks-generation := transform:transform($tasks-input,$tasks-xsl,$param)
                        let $store-return-status := xmldb:store($collection,$tasks-file,$tasks-generation)
                        (: Generate Day SVG :)
                        let $days-file := 'CalendarXTransformDay.xml'
                        let $days-input := doc('/db/apps/praktikum/simpleEvents.xml')
                        let $days-xsl := doc('/db/apps/praktikum/CalendarXTransformDay.xslt')
                        let $days-generation := transform:transform($days-input,$days-xsl,$param)
                        let $store-return-status := xmldb:store($collection,$days-file,$days-generation)
                        (: Generate Weeks SVG :)
                        let $weeks-file := 'CalendarXTransformWeek.xml'
                        let $weeks-input := doc('/db/apps/praktikum/simpleEvents.xml')
                        let $weeks-xsl := doc('/db/apps/praktikum/CalendarXTransformWeek.xslt')
                        let $weeks-generation := transform:transform($weeks-input,$weeks-xsl,$param)
                        let $store-return-status := xmldb:store($collection,$weeks-file,$weeks-generation)
                        return 
                               transform:transform($input, $xsl, $param)
)else(
"den doulevi"
)

let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="test" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <head>
        <link rel="stylesheet" href="screen.css" media="all" type="text/css"/>
        <xf:model id="viewModel">
            <xf:instance xmlns="" id="dateData">
                <root>
                    <date/>
                    <mode/>
                </root>
            </xf:instance>
            <xf:instance id="view">
                <svg>
                picture</svg>
            </xf:instance>
            <xf:instance id="viewResult">
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:foo="http://www.foo.org" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%"/>
            </xf:instance>
            <xf:submission id="getView" method="post" replace="all" action="getViews.xqm"/>
            <xf:bind nodeset="instance('dateData')//date" type="xs:date"/>
            <xf:bind nodeset="instance('dateData')//mode" type="xs:string"/>
        </xf:model>
        <title>Calendar Forms </title>
    </head>
    <body>
        <div id="wrapper">
            <h1> Calendar System </h1>
            <div id="views">
                <xf:group id="selectionView" model="viewModel">
                    <xf:input id="date" ref="instance('dateData')//date">
                        <xf:label>Enter a date: </xf:label>
                    </xf:input>
                    <br/>
                    <xf:trigger>
                        <xf:label>Day View</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('dateData')//mode">Day</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Week View</xf:label>
                        <xf:action>
                            <xf:setvalue ref="instance('dateData')//mode">Week</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger>
                        <xf:label>Month View</xf:label>
                        <xf:action  ev:event="xforms-activate">
                            <xf:setvalue ref="instance('dateData')//mode">Month</xf:setvalue>
                            <xf:send submission="getView"/>
                        </xf:action>
                    </xf:trigger>
                </xf:group>
                <div id="svgs"/>
                <xf:group id="createTaskG">
                    <xf:trigger>
                        <xf:label>Create Task</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:load show="replace" resource="createTask.xhtml"/>
                        </xf:action>
                    </xf:trigger>
                </xf:group>
            </div>
            <div id="calendarView">
                {$svg}
                         
            </div>
        </div>
    </body>
</html>
)
(:
let $finalTransform := doc('/db/apps/xsltforms/xsltforms.xsl')

let $dummyParams := 
<parameters>
   <param name="omit-xml-declaration" value="yes"/>
   <param name="indent" value="no"/>
   <param name="media-type" value="text/html"/>
   <param name="method" value="xhtml"/>
   <param name="baseuri" value="/exist/rest/db/xforms/xsltforms/"/> 
</parameters>

let $serialization-options := 'method=xml media-type=text/html omit-xml-declaration=yes indent=no'
let $dispatchForm := transform:transform($form,$finalTransform,$dummyParams) :)
        let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
        let $debug := processing-instruction xsltforms-options {'debug="yes"'}
return

  ($xslt-pi,$debug,$form)