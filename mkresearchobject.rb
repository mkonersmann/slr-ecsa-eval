#!/usr/bin/env ruby
# encoding: utf-8

#method definitions

#Compute the Percentile of an ordered Array
#params
# a: a sorted array
# p: a percentile, a float between 0.0 and 100.0 (inclusive)
#return
# the estimated percentile of the value after NIST
def percentile(a,p)
  raise "%f must be in [0,100]"%p if p<0.0 or p>100.0
  return nil                      if a.empty? 
  return a[0]                     if a.length==1
  r=(p.to_f/100.0)*(a.length-1)+1
  i=r.to_i
  f=(r-i).abs
  return a[i-1]                   if f==0.0 
  return f*(a[i]-a[i-1])+a[i-1] 
end

class String

 def to_ref
  self.downcase.gsub("ä","ae").gsub("ö","oe").gsub("ü","ue").gsub("ß","ss").gsub(" ","")
 end

 def to_tex
  self.gsub("ä","\\\"a").gsub("ü","\\\"u").gsub("ö","\\\"o").gsub("ß","\\ss{}")
 end

end

filename="data/Unique_Research_Objects.csv"
datadir="./figs/"
outputdir="diagrams/"
seperator="|"

#todo: refactor to make it like FBP (use classes)
#todo: include computation of Boxplots
#todo: include diagrams for 2 Dimensionals (with Ranges or Sets)

#module read file
unless File.exists?(filename)
 puts"the given file %s did not exist"
 exit(1)
end

keys=nil
values=[]

puts "reading file: %s" % filename
open(filename) do|f|
 f.each do|line|
  if keys.nil?
   keys=line.strip.split(seperator).map{|x| x.strip}
  else
   values << line.strip.split(seperator).map{|x| x.strip } # .gsub(/([0-9]+),([0-9]+)/,"\1.\2") BUG:gsub does not work correctly 
  end
 end
end

if values.empty?
 puts("The file did not contain any data rows")
 exit(2)
end

puts "found %d data rows" % values.size

#module generate histograms

puts keys

histograms=[]
0.upto(keys.size-1) do|i|
 histograms << Hash.new
 histograms.last.default=0
 values.each do|x|
  (x[i].strip.split(",").map{|e| e.strip.downcase}).each do|v|
   histograms.last[v]+=1
  end
 end
end

puts histograms

# module print qualities

puts "=== Summary of found qualities ==="

0.upto(keys.size-1) do|i|
 v=histograms[i].keys
 if v.size==values.size
  puts "%s" % keys[i]
 else
  puts "%s:%s" % [ keys[i],v.join(",") ] 
 end
end

#module print histograms

puts "=== Human readable Histograms ==="

0.upto(keys.size-1) do|i|
 puts "Histrogram for %s (%d)" % [keys[i], histograms[i].size]
 histograms[i].each_pair do|k,v|
  puts " %s : %d" % [k,v]
 end
end

#module print histograms for latex

puts "=== Latex includable Histograms ==="

auswahl=<<-eos
Research Object:Architecture Analysis Method,Architecture Design Method,Architecture Optimization Method,Architecture Evolution,Architecture Description Language,Architecture Decision Making,Reference Architecture,Architecture Pattern,Architecture Description,Architectural Aspects,Teaching,Technical Dept,Quality Evolution,Architecture Extraction,Architectural Assumptions

Year:2016,2017,2018,2019,2020

eos

#texfile=outputdir+"research_objects_histogram.tex"
#tex=open(texfile,"w+")
tex=nil
unless tex
 tex=STDOUT 
else
 puts "safed to %s" % texfile
end

template=<<-eos
%\\subsection{<caption>}
%\\begin{figure}
\\begin{center}
\\begin{tikzpicture}[scale=.8]
\\begin{axis}[ ybar, ymajorgrids, enlargelimits=0.15, legend style={at={(0.5,-0.15)}, anchor=north,legend columns=-1},
    width=.90\\linewidth,height=10cm,
    nodes near coords, %nodes near coords align=below,
    ylabel={Count}, ymin=0,
    x tick label style={rotate=45,anchor=east},
    xtick={<numbers>},
    xticklabels={<labels>}
    %xlabel={<xlabel>}    
    ]
  \\addplot coordinates { <coordinates>  };
\\end{axis}
\\end{tikzpicture}
\\end{center}
%\\caption{<caption>}
%\\label{fig:<reflabel>}
%\\end{figure}

eos

auswahl.each_line do|line|
 ary=line.split(":")
 next if ary.size!=2
 i=keys.index(ary[0])
 v=ary[1].split(",").map{|s| s.strip}
 next if i.nil? or histograms[i].size==0

 caption=("Histogramm für %s (%d)" % [ary[0], histograms[i].values.inject(0){|s,x| s+x}])
 size=v.size
 numbers=((1..size).to_a.join(","))
 labels=ary[1]
 xlabel=ary[0]
 h=histograms[i]
 coordinates=(1..size).to_a.map{|n| "(%d,%d) " % [n, h[v[n-1].downcase]] }.join(" ")
 ref="histo_%s" % xlabel.to_ref

 t=String.new(template)
 t.gsub!("<numbers>",numbers)
 t.gsub!("<labels>",labels.gsub("%","\\%"))
 t.gsub!("<xlabel>",xlabel)
 t.gsub!("<coordinates>",coordinates)
 t.gsub!("<caption>",caption)
 t.gsub!("<reflabel>",ref)
 #Latex conversion
 #tex.puts t.to_tex
 puts datadir+ref+".tex"
 open(datadir+ref+".tex","w+") {|f| f.puts t.to_tex }
end

tex.close if tex!=STDOUT
tex=nil

# Modul für 2-D Diagrams Latex (Quantitäten und Qualitäten)

puts "=== Latex includable 2-D Diagrams ==="

auswahl=<<-eos
eos
#Does not work: index returned nil but max can not handle nil
#Nutzung von Förderung:keine,selten,gelegentlich,oft|Strategische Weiterentwicklung:gar nicht,Produktisierung,Plattformentwicklung,Frameworkentwicklung

#texfile=outputdir+"dia2.tex"
#tex=open(texfile,"w+")
tex=nil
unless tex
 tex=STDOUT 
else
 puts "safed to %s" % texfile
end

template=<<-eos
%\\subsection{<caption>}
%\\begin{figure}
\\begin{center}
\\begin{tikzpicture}
 \\begin{axis}[
     grid=major,
     only marks,
     enlargelimits=0.15,
     legend style={at={(0.5,-0.15)}, anchor=north,legend columns=-1},
     <xaxis>,
     <yaxis>
    ]
  \\addplot coordinates{<coordinates>};
 \\end{axis}
\\end{tikzpicture}
\\end{center}
%\\caption{<caption>}\\label{fig:<reflabel>}
%\\end{figure}

eos

auswahl.each_line do|line|
 ary=line.split("|").map{|s| s.strip}
 next if ary.size!=2
 ary.map!{|x| x.split(":").map{|s| s.strip} }

 x_i=keys.index(ary[0][0])
 x_range=(ary[0].length==1)
 y_i=keys.index(ary[1][0])
 y_range=(ary[1].length==1)
 next if x_i.nil? or y_i.nil?

 xaxis=if x_range 
        xcontent=values.collect{|x| x[x_i]}         
        "xlabel=%s" % ary[0][0]
       else 
         xlabels=ary[0][1].split(",").map{|e| e.strip}
         l=xlabels.map{|l| l.downcase}
         xcontent=values.collect {|x| (x[x_i].split(",").map{|e| l.index(e.strip.downcase) }.max) }
         "xtick={%s}, xticklabels={%s}, x tick label style={rotate=45,anchor=east}" % [(0...xlabels.size).to_a.join(","),xlabels.join(",")]
       end
 yaxis=if y_range 
         ycontent=values.collect{|x| x[y_i]}
         "ylabel=%s" % ary[1][0]
       else 
         ylabels=ary[1][1].split(",").map{|e| e.strip}
         l=ylabels.map{|l| l.downcase}
         ycontent=values.collect {|x| (x[y_i].split(",").map{|e| l.index(e.strip.downcase) }.max) }
         "ytick={%s}, yticklabels={%s}" % [(0...ylabels.size).to_a.join(","),ylabels.join(",")]
       end

 caption=("Gegenüberstellung von %s und %s" % [ary[0][0],ary[1][0]])
 ref="2d_%s_%s" % [ary[0][0],ary[1][0]].map{|x| x.to_ref }
 coordinates=xcontent.zip(ycontent).map{|x| "(%s,%s)"%x }.join(" ")

 t=String.new(template)
 t.gsub!("<xaxis>",xaxis)
 t.gsub!("<yaxis>",yaxis)
 t.gsub!("<coordinates>",coordinates)
 t.gsub!("<caption>",caption)
 t.gsub!("<reflabel>",ref)
 #Latex conversion
 #tex.puts t.to_tex
 puts datadir+ref+".tex"
 open(datadir+ref+".tex","w+") {|f| f.puts t.to_tex }
end

tex.close if tex!=STDOUT
tex=nil

# Modul for Pie-Charts

puts "=== Latex Pie-Charts==="

auswahl=<<-eos
Research Object:Architecture Analysis Method,Architecture Design Method,Architecture Optimization Method,Architecture Evolution,Architecture Description Language,Architecture Decision Making,Reference Architecture,Architecture Pattern,Architecture Description,Architectural Aspects,Teaching,Technical Dept,Quality Evolution,Architecture Extraction,Architectural Assumptions

eos

#texfile=outputdir+"research_objects_pie.tex"
#tex=open(texfile,"w+")
tex=nil
unless tex
 tex=STDOUT 
else
 puts "safed to %s" % texfile
end

tex.puts "\\newcounter{piea}\n\\newcounter{pieb}\n\n"

template=<<-eos

%\\subsection{<caption>}
%\\begin{figure}
\\begin{center}
\\begin{tikzpicture}[scale=2]
\\pgfmathsetcounter{pieb}{0}
\\foreach \\p/\\q/\\t/\\c in {<segments>}
  {
    \\setcounter{piea}{\\value{pieb}}
    \\addtocounter{pieb}{\\q}
    \\slice{\\thepiea/<sum>*360}
          {\\thepieb/<sum>*360}
          {\\p\\%}{\\t}{\\c}
  }
\\end{tikzpicture}
\\textbf{<caption>}
\\end{center}
%\\caption{<caption>}
%\\label{fig:<reflabel>}
%\\end{figure}

eos

auswahl.each_line do|line|
 ary=line.split(":")
 next if ary.size!=2
 i=keys.index(ary[0])
 v=ary[1].split(",").map{|s| s.strip}
 next if i.nil? or histograms[i].size==0

 size=v.size
 h=histograms[i]
 sum=(v.map{|k| h[k.downcase]}).inject(0){|s,e| s+e}
 caption=("Pie chart for %s (%d)" % [ary[0], sum])
 puts caption
 color=10
 segments=v.map{|k| "%.0f/%d/%s/blue!%d"%[(h[k.downcase]*100.0)/sum,h[k.downcase],k,color+=10] }.join(", ")
 ref="pie_%s" % ary[0].to_ref

 t=String.new(template)
 t.gsub!("<sum>",sum.to_s)
 t.gsub!("<segments>",segments)
 t.gsub!("<caption>",caption)
 t.gsub!("<reflabel>",ref)
 #Latex conversion
 #tex.puts t.to_tex
 puts datadir+ref+".tex"
 open(datadir+ref+".tex","w+") {|f| f.puts t.to_tex }
end

tex.close if tex!=STDOUT
tex=nil


# Modul für Vergleich von Histogrammen

puts "=== Latex includable Comparable Histograms ==="

auswahl=<<-eos
Year:2016,2017,2018,2019,2020|Research Object:Architecture Analysis Method,Architecture Design Method,Architecture Optimization Method,Architecture Evolution,Architecture Description Language,Architecture Decision Making,Reference Architecture,Architecture Pattern,Architecture Description,Architectural Aspects,Teaching,Technical Dept,Quality Evolution,Architecture Extraction,Architectural Assumptions

eos

#texfile=outputdir+"research_objects_stacked.tex"
#tex=open(texfile,"w+")
tex=nil
unless tex
 tex=STDOUT 
else
 puts "safed to %s" % texfile
end

template=<<-eos
%\\subsection{<caption>}
%\\begin{figure}
\\begin{center}
\\begin{tikzpicture}[scale=0.8]
\\
\\begin{axis}[ width=\\linewidth, height=9cm, ybar stacked,
    cycle multi list=Spectral,
    every axis plot/.append style={draw,fill,fill opacity=0.5},
    nodes near coords, %nodes near coords align=below,
    nodes near coords style={color=black,font=\\small},
    enlargelimits=0.15, 
    bar width=3.5em,
    legend style={at={(0.5,1.45)}, anchor=north,legend columns=2},
    legend cell align={left},
    ylabel={<ylabel>},ymajorgrids,ymin=0,
    %x tick label style={rotate=45,anchor=east},
    xtick={<numbers>}, xticklabels={<labels>},
    xlabel={<xlabel>}    
   ]
<plots>
\\legend{<legend>}
\\end{axis}
\\end{tikzpicture}
\\end{center}
%\\caption{<caption>}
%\\label{fig:<reflabel>}
%\\end{figure}

eos

auswahl.each_line do|line|
 ary=line.split("|").map{|s| s.strip.split(":").map{|s| s.strip} }
 ary.flatten!
 next if ary.size!=4
 x_i=keys.index(ary[0])
 y_i=keys.index(ary[2])
 next if x_i.nil? or y_i.nil?
 x_keys=ary[1].split(",").map{|s| s.strip}
 y_keys=ary[3].split(",").map{|s| s.strip}

 h_values=Hash.new
 y_keys.each do|yk|
  h_values[yk]=Hash.new
  h_values[yk].default=0
  values.select do|x|
   (x[y_i].strip.split(",").map{|e| e.strip.downcase}).include?(yk.downcase)
  end.each do|x|
   x_keys.each do|xk|
    h_values[yk][xk]+=x[x_i].strip.split(",").count{|e| e.strip.downcase==xk.downcase}
   end
  end
 end


 size=x_keys.size
 numbers=((1..size).to_a.join(","))
 labels=x_keys.join(",")
 xlabel=ary[0]
 ylabel=ary[2]
 caption=("Histogram von %s je %s" % [ary[0],ary[2]])
 plots=""
 legend=y_keys.join(",")
 plots=y_keys.map do|yk|
         h=h_values[yk]
         xs=h.values.inject(0){|s,x| s+x}
         #"\\addplot coordinates { %s };\n" % ( (1..size).to_a.map{|n| "(%d,%.0f) " % [n, (h[x_keys[n-1]]*100.0)/xs ] }.join(" ") )
         "\\addplot coordinates { %s };\n" % ( (1..size).to_a.map{|n| "(%d,%d) " % [n, h[x_keys[n-1]]] }.join(" ") ) 
       end.join
 puts caption
 ref="chisto_%s_%s" % [ary[0],ary[2]].map{|x| x.to_ref }

 t=String.new(template)
 t.gsub!("<numbers>",numbers)
 t.gsub!("<labels>",labels)
 t.gsub!("<xlabel>",xlabel)
 t.gsub!("<ylabel>",ylabel) 
 t.gsub!("<plots>",plots)
 t.gsub!("<caption>",caption)
 t.gsub!("<legend>",legend)
 t.gsub!("<reflabel>",ref)
 #Latex conversion
 #tex.puts t.to_tex
 puts datadir+ref+".tex"
 open(datadir+ref+".tex","w+") {|f| f.puts t.to_tex }
end

tex.close if tex!=STDOUT
tex=nil
