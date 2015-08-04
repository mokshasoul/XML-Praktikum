xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";


let $parameterNames := request:get-data()
let $eventDate := $parameterNames//date
let $eventMode := $parameterNames//mode
return
<root>
    <name>{$parameterNames}</name>
   <date>{$eventDate}</date>
   <mode>{$eventMode}</mode>
</root>
   