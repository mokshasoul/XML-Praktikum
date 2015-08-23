xquery version "3.0";

(: echo-post.xq: Return all data from an HTTP post to the caller. 
 transform:transform($input, $xsl, $param)
 :)
import module namespace getEvents = "http://www.getEvents.com" at 'getEventsFunctions.xqm';
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/xml indent=no  process-xsl-pi=no";

let $collection :=  'xmldb:exist:///db/apps/praktikum'
let $login := xmldb:login($collection, 'admin', '')
let $attribute := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')

let $form := (
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
    <head>
        <link href="screen.css" rel="stylesheet" type="text/css" />

        <xf:model xmlns="" id="appendData">
            <xf:instance xmlns="" id="dataI">
                <root>
                    <description/>                    
                    <category/>
                    <startDate/>
                    <endDate/>
                    <startTime/>
                    <endTime/>
                                        <restrictDate />
                    <note/>
                    <attendees>
                    </attendees>
                    <location/>
                    <repeat />
                    <patternType />
                    <repeatDayOfWeek />
                      <monthlyCardinalOrOrdinal />

                    <yearlyCardinalOrOrdinal />
                    <ordinalType/>
                </root>
            </xf:instance>
            <xf:bind ref="description" required="true()" type="xs:string"/>
            <xf:bind ref="startDate" required="true()" type="xs:date"/>
            <xf:bind ref="endDate" required="false()" type="xs:date" relevant="instance('dataI')//restrictDate[.='true']" />
            <xf:bind ref="startTime" required="false()" type="xs:string"/>
            <xf:bind ref="endTime" required="false()" type="xs:string"/>
            <xf:bind ref="attendees" required="false()" type="xs:string"/>
            <xf:bind ref="location" required="false()"/>
            <xf:bind ref="repeat" required="false()" type="xs:boolean"/>
            <xf:bind ref="patternType" required="false()" relevant="instance('dataI')//repeat[.='true']" />
            <xf:bind ref="repeatDayOfWeek" required="false()" type="xs:string" relevant="instance('dataI')//repeat[.='true'] and instance('dataI')//patternType[.='weeklyPattern']" />
            <xf:bind ref="monthlyCardinalOrOrdinal" required="false()" type="xs:string" relevant="instance('dataI')//repeat[.='true'] and instance('dataI')//patternType[.='monthlyPattern']" />
            <xf:bind ref="ordinalType" required="true()" type="xs:string" relevant="instance('dataI')//repeat[.='true'] and (instance('dataI')//patternType[.='monthlyPattern'] or instance('dataI')//patternType[.='yearlyPattern']) and (instance('dataI')//monthlyCardinalOrOrdinal[.='monthlyOrdinal'] or instance('dataI')//yearlyCardinalOrOrdinal[.='yearlyOrdinal'])"/>
            <xf:bind ref="restrictDate" required="false()" type="xs:boolean"/>
           <xf:bind ref="yearlyCardinalOrOrdinal" required="false()" type="xs:string" relevant="instance('dataI')//repeat[.='true'] and instance('dataI')//patternType[.='yearlyPattern']" />
                    <xf:submission id="convert" method="post" replace="none" action="../edit/addEvents.xqm">
                <xf:action ev:event="xforms-submit-error">
                    <xf:message>An Error has occured. Please check your Input.</xf:message>
                </xf:action>
                <xf:action ev:event="xforms-submit-done">
                    <xf:message>Task Created! You Can Close The Window Now or Create New Task</xf:message>
                    <xf:reset model="appendData"/>
                </xf:action>
            </xf:submission>
        </xf:model>
        <title/>
    </head>
    <body>
         <div id="wrapper">
         <div id="wrapperPropper">
        <div id="form-heading">Create New Task</div>
        <div id="navBar">
            <ul>
                <li>
                    <a href="getViews.xqm">Home</a>
                </li>
            </ul>
        </div>
    
        <div id="inputBlock" class="inputBlock">
            <xf:group model="appendData" appearance="bf:verticalTable">
                <xf:input ref="instance('dataI')//description">
                    <xf:label class="inputLabels">Task Name:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//category">
                    <xf:label  class="inputLabels">Task Category:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//startDate">
                    <xf:label  class="inputLabels">Start Date:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//restrictDate" id="restriction">
                    <xf:label>End Datum? </xf:label>
                    </xf:input>
               <xf:input ref="instance('dataI')//endDate">
                    <xf:label class="inputLabels">End Date:</xf:label>
               </xf:input>
                <xf:input ref="instance('dataI')//startTime">
                    <xf:label  class="inputLabels">Start Time:</xf:label>
                </xf:input>

                <xf:input ref="instance('dataI')//endTime">
                    <xf:label  class="inputLabels">End Time:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//note">
                    <xf:label  class="inputLabels">Additional Comments:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//attendees">
                    <xf:label  class="inputLabels">Attendee:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//location">
                    <xf:label  class="inputLabels">Location:</xf:label>
                </xf:input>
                <xf:input ref="instance('dataI')//repeat">
                    <xf:label class="inputLabels">Repeat:</xf:label>
                </xf:input>
                
                <xf:select1 ref="patternType" appearance="minimal">
                    <xf:label>How often should the event occur?</xf:label>
                    <xf:item>
                        <xf:label>Every Day</xf:label>
                        <xf:value>dailyPattern</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Every Week</xf:label>
                        <xf:value>weeklyPattern</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Every Month</xf:label>
                        <xf:value>monthlyPattern</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Every Year </xf:label>
                        <xf:value>yearlyPattern</xf:value>
                    </xf:item>
                </xf:select1>
                
                <xf:select ref="repeatDayOfWeek" appearance="full">
                    <xf:item>
                           <xf:label>Monday</xf:label>
                           <xf:value>monday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Tuesday</xf:label>
                           <xf:value>tuesday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Wednesday</xf:label>
                           <xf:value>wednesday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Thursday</xf:label>
                           <xf:value>thursday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Friday</xf:label>
                           <xf:value>friday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Saturday</xf:label>
                           <xf:value>saturday</xf:value>
                    </xf:item>
                    <xf:item>
                           <xf:label>Sunday</xf:label>
                           <xf:value>sunday</xf:value>
                    </xf:item>
                </xf:select> 
                                <xf:select1 ref="monthlyCardinalOrOrdinal" appearance="full">
                    <xf:label>Select ordinal or cardinal?</xf:label>
                    <xf:item>
                        <xf:label>Day of the month (cardinal)</xf:label>
                        <xf:value>monthlyCardinal</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Day of the week (ordinal)</xf:label>
                        <xf:value>monthlyOrdinal</xf:value>
                    </xf:item>
                </xf:select1>
                <xf:select1 ref="ordinalType" appearance="minimal">
                    <xf:label>Ordinality:</xf:label>
                    <xf:item>
                        <xf:label>First Day Of Month </xf:label>
                        <xf:value>first</xf:value>
                    </xf:item>
                                        <xf:item>
                        <xf:label>Second Day Of Month </xf:label>
                        <xf:value>second</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Third Day Of Month </xf:label>
                        <xf:value>third</xf:value>
                    </xf:item>
                                        <xf:item>
                        <xf:label>Fourth Day Of Month </xf:label>
                        <xf:value>fourth</xf:value>
                    </xf:item>
                                        <xf:item>
                        <xf:label>Second To Last Day Of Month </xf:label>
                        <xf:value>penultimate</xf:value>
                    </xf:item>
                                        <xf:item>
                        <xf:label>Last Day Of Month </xf:label>
                        <xf:value>ultimate</xf:value>
                    </xf:item>
                  </xf:select1>
                    <xf:select1 ref="yearlyCardinalOrOrdinal" appearance="full">
                    <xf:label>Select ordinal or cardinal?</xf:label>
                    <xf:item>
                        <xf:label>Day of the month (cardinal)</xf:label>
                        <xf:value>yearlyCardinal</xf:value>
                    </xf:item>
                    <xf:item>
                        <xf:label>Day of the week (ordinal)</xf:label>
                        <xf:value>yearlyOrdinal</xf:value>
                    </xf:item>
                </xf:select1>
              </xf:group>
              
              <xf:submit submission="convert">
                  <xf:label>Create New Task</xf:label>
              </xf:submit>
            </div>
            </div>
        </div>
    </body>
</html>)
let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}   
return
  ($xslt-pi,$form)