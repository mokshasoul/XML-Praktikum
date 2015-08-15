xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace updateFunction = "http://www.update.com" at 'updateTesting.xqm';
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

let $dbCal := doc('/db/apps/praktikum/data/sampleCalendarX.xml')
let $seriesProc := if (not($post-req//series = 'true')) then
(
updateFunction:updateSeries($post-req)
)else(
updateFunction:updateOccurence($post-req)
)
    return
    <root>
{$seriesProc}
</root>