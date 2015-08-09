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
    (:POST parameters:)
               let $param1 := xs:string('Day')
               let $param2 := xs:date('2015-06-16')
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
                               
                        
