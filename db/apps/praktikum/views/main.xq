
xquery version "3.0";

import module namespace getEvents = "http://www.getEvents.com" at '/db/apps/praktikum/views/getEventsFunctions.xqm';


let $date:=xs:date('2015-06-09')
return  getEvents:getEventsForDay($date) 