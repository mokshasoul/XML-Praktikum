xquery version "1.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. :)

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace dayView="http://dayView.com" at 'getEventsForDate.xq';
declare option exist:serialize "method=xml media-type=text/xml indent=yes";

let $xsl := doc('/db/apps/praktikum/CalendarXTransformDay.xslt')
let $post-data := request:get-data() 

let $day := fn:day-from-date($post-data//data/date)
let $month :=fn:month-from-date($post-data//data/date)
let $year := fn:year-from-date($post-data//data/date)
let $input := dayView:view($post-data)

let $param := <parameters><param name="requestedDate" value="{$post-data}" /></parameters>
                            

return
    transform:transform($input, $xsl, $param)