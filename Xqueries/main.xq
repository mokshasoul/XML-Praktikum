xquery version "3.0";

import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';


let $date:=xs:date('2015-06-09')
return  getEvents:getEventsForMonth($date) 
 
