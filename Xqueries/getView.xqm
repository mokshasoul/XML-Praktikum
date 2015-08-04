xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=svg media-type=application/svg+xml omit-xml-declaration=no indent=yes";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $post-req := request:get-data()
let $param1 := $post-req//mode
let $param2 := xs:date($post-req//date)
let $concat1 := concat("/db/apps/praktikum/CalendarXTransform",$param1,".xslt")


let $xsl := doc($concat1)

let $xq := if ($param1="Day")
then  getEvents:getEventsForDay($param2)
else if ($param1="Week")
then getEvents:getEventsForWeek($param2)
else getEvents:getEventsForMonth($param2)
      
let $input := doc('/db/apps/praktikum/simpleEvents.xml')
let $param := <parameters><param name="requestedDate" value="{$param2}" /></parameters>
(:First Generate sampleEvents.xml 
  Then generate all SVGs in order to REF id's
  After that return a complete SVG( MONTHS WILL BE A POTENTIAL PROBLEM MAYBE SAVE FROM XSLT DIRECT TO GENERATED XML????)
  let $param1 := request:get-parameter('mode','')
    let $param2 := xs:date(request:get-parameter('date',''))
    let $post-req := request:get-data()
let $param1 := $post-req//mode
let $param2 := xs:date($post-req//date)
:)
(: TODO DONNERSTAG!!!! :)
(: Generate Events Files 
let $events-file := 'simpleEvents.xml'
let $events-input := doc('/db/apps/praktikum/sampleEvents.xml')
let $events-xsl := doc('/db/apps/praktikum/SimpleEvents.xsl')
let $events-generation := transform:transform($events-input,$events-xsl,$param)
let $store-return-status := xmldb:store($collection, $events-file, $events-generation):)
let $events-file := 'simpleEvents.xml'
let $store-return-status := xmldb:store($collection, $events-file, $xq)
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
(:debugging 
transform:transform($input, $xsl, $param)


let $weeks-file := 'CalendarXTransformWeek.xml'
let $weeks-input := doc('/db/apps/praktikum/simpleEvents.xml')
let $weeks-xsl := doc('/db/apps/praktikum/CalendarXTransformWeek.xslt')
let $weeks-generation := transform:transform($weeks-input,$weeks-xsl,$param)
let $store-return-status := xmldb:store($collection,$weeks-file,$weeks-generation)

transform:transform($input, $xsl, $param)
:)

let $dispatch := transform:transform($input,$xsl,$param)
let $dispatch-doc:= 'dispatch.xml'
let $store-return-status := xmldb:store($collection,$dispatch-doc,$dispatch)
return
    <root>
    {$xq}
    </root>
(: return whatever transformation we want to get :)
