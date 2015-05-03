import csv

f=open('tasks.csv')
f_out=open('codea.text','w')
f_out2=open('codeb.text','w')
csv_f= csv.reader(f)
for row in csv_f:
    name = "T2015-{}-{}_{}".format(row[0],row[1],row[2])
   
    print("""<g id='{}'>
                <use xlink:href='#APP'/>
                <text transform='translate(0,15) scale(1.2,1)' font-size='32' >
                    <tspan x='10' y='10' font-size='16'>{}</tspan>
                    <tspan x='100' y='15' font-weight='bold'>{}</tspan>
                   <tspan x='10' y='50'>{}</tspan>
               </text>
           </g>\n""".format(name,row[3],row[4],row[5]), file=f_out)
    
    print("""
<g transform='translate(0,{})'>
    <use xlink:href='Tasks.svg#{}' transform='scale(0.95,1.2) translate(15,20)' />
</g>\n""".format(row[6],name), file=f_out2)
    
print("succes")
