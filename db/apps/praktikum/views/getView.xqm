xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";


let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $post-req := request:get-data()
let $param1 := $post-req//mode
let $param2 := xs:date($post-req//date)
let $concat1 := concat("/db/apps/praktikum/views/CalendarXTransform",$param1,".xslt")


let $xsl := doc($concat1)

let $xq := if ($param1="Day")
then  getEvents:getEventsForDay($param2)
else if ($param1="Week")
then getEvents:getEventsForWeek($param2)
else getEvents:getEventsForMonth($param2)
      
let $param := <parameters><param name="requestedDate" value="{$param2}"/></parameters>
(:First Generate sampleEvents.xml 
  Then generate all SVGs in order to REF id's
  After that return a complete SVG( MONTHS WILL BE A POTENTIAL PROBLEM MAYBE SAVE FROM XSLT DIRECT TO GENERATED XML????)
    let $post-req := request:get-data()
let $param1 := $post-req//mode
let $param2 := xs:date($post-req//date)
:)
(: TODO DONNERSTAG!!!! :)
(: Generate Events Files :)
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

(: return whatever transformation we want to get :)