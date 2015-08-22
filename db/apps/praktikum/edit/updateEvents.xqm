xquery version "3.0";

(:
Purpose of this file is to handle the 2 different cases of event editing
The functions themselves are saved in updateTesting.xqm
 :)
import module namespace updateFunction = "http://www.update.com" at 'updateFunctions.xqm';
import module namespace helper = "http://www.help.com" at '../views/helperFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $dbCal := helper:calendarDoc()

let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
let $post-req := request:get-data()

let $seriesProc := if (not(xs:boolean($post-req//series))) then
(
updateFunction:updateSeries($post-req)
)else(
updateFunction:updateOccurence($post-req)
)   
    return
    <root>
{$dbCal}
</root>