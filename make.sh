#!/bin/bash

INPUT="Normalized_Data.csv";

DATADIR="data";
REDUCED="$DATADIR/Reduced_Normalized_Data.csv";

# reduce data

echo "$REDUCED"

mkdir -p "$DATADIR"
cut -d"|" -f1,3,4,6,8,10,15-17,19,21,22,23 "$INPUT" > "$REDUCED";

# Overview table

OVERVIEW="$DATADIR/Overview.csv";

echo "$OVERVIEW";

echo "Year;Paper ID;Research Objects;Evaluation Methods;Properties" > "$OVERVIEW";
#tail -n+2 "$REDUCED" | cut -d"|" -f1,2,3,4,6 | sort -u >> "$OVERVIEW";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,3,4,6 | awk -F"|" -f overview.awk | sort >> "$OVERVIEW"

#Table found in tables/overview.tex

# 1.	What has been in the last years and how did it change?

RESEARCHOBJECTS="$DATADIR/Unique_Research_Objects.csv";
EVALUATIONTYPES="$DATADIR/Unique_Evaluation_Methods.csv";
THREATSTOVALIDITY="$DATADIR/Unique_Threats_to_Validity.csv";
ARTIFACTEVALUATION="$DATADIR/Unique_Artifact_Evaluation.csv";

# 1.1.	What is the fraction of Research Objects in the body of literature? (Do thesefractions change over the five years surveyed?)

echo "$RESEARCHOBJECTS"

echo "Year|Paper ID|Research Object" > "$RESEARCHOBJECTS";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,3 | sort -u >> "$RESEARCHOBJECTS";

#creates research_objects_* diagrams
ruby mkresearchobject.rb

# 1.2.	What is the fraction of Evaluation Methods employed by papers in the body of literature? (Do these fractions change over the five years surveyed?)

echo "$EVALUATIONTYPES"

echo "Year|Paper ID|Research Object|Evaluation Methods" > "$EVALUATIONTYPES";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,3,4 | sort -u | awk -F"|" '{if(a[$2"|"$3]) a[$2"|"$3]=a[$2"|"$3]","$4; else a[$2"|"$3]=$4; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' - >> "$EVALUATIONTYPES";

#creates evaluation_methods_* diagrams
ruby mkevaluationmethod.rb

# 1.3.	What is the fraction of papers for which an artifact was provided for replication?

echo "$ARTIFACTEVALUATION"

echo "Year|Paper ID|Tool Prototype|Input Data|Replication Package" > "$ARTIFACTEVALUATION";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,7,8,9 | sort -u >> "$ARTIFACTEVALUATION";

ruby mkartifactevaluation.rb

echo "$THREATSTOVALIDITY"

echo "Year|Paper ID|Threats to Validity" > "$THREATSTOVALIDITY";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,12 | sort -u >> "$THREATSTOVALIDITY";

ruby mkthreatstovalidity.rb



# 2.	Which relations exist?

KIND_EVALUATION="$DATADIR/Kind_to_Evaluation_Method.csv";
RO_PROPERTIES="$DATADIR/Research_Object_to_Property_Instances.csv";
PROP_EVALUATION="$DATADIR/Property_Instances_to_Evaluation_Method.csv";
ET_THREATS="$DATADIR/Evaluation_Method_to_Threats_to_Validity.csv";
#ET_ARTIFACTS="$DATADIR/Evaluation_Method_to_Artifacts.csv";
GUIDELINES="$DATADIR/Guidelines.csv"

# 2.1.	In the surveyed body of literature, can we find a relationship between the kind of paper (e.g., industry paper) and the Evaluation Methods?

echo "$KIND_EVALUATION"

echo "Year|Paper ID|Industry Paper|Evaluation Methods" > "$KIND_EVALUATION";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,4,13 | sort -u | awk -F"|" '{ a[$2]=$1; if(c[$2]) c[$2]=c[$2]","$3; else c[$2]=$3; d[$2]=$4; }END{for (i in a) print a[i]"|"i"|"d[i]"|"c[i]; }' | sort >> "$KIND_EVALUATION";

ruby mkkindperevaluation.rb



# 2.2.	In the surveyed body of literature, what is the relationship between Research Object and Property evaluated?

echo "$RO_PROPERTIES"

echo "Year|Paper ID|Research Object|Property Instance" > "$RO_PROPERTIES";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,3,6 | sort -u | awk -F"|" '{if(a[$2"|"$3]) a[$2"|"$3]=a[$2"|"$3]","$4; else a[$2"|"$3]=$4; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' - | sort >> "$RO_PROPERTIES";

ruby mkresearchperproperties.rb

# 2.3.	In the surveyed body of literature, what is the relationship between properties evaluated and Evaluation Methods?

echo "$PROP_EVALUATION"

echo "Year|Paper ID|Property Instance|Evaluation Method" > "$PROP_EVALUATION";
tail -n+2 "$REDUCED" | awk -F"|" '{print $1"|"$2"|"$6"|"$4}' - | sort -u >> "$PROP_EVALUATION";

#tail -n+2 "$REDUCED" | cut -d"|" -f1,2,6,4 | sort -u | awk -F"|" '{if(a[$2"|"$3]) a[$2"|"$3]=a[$2"|"$3]","$4; else a[$2"|"$3]=$4; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' - >> "$PROP_EVALUATION";

ruby mkpropertyperevaluation.rb


# 2.4.	In the surveyed body of literature, which threats to validity are typically addressed for which Evaluation Method?
# 2.5.	In the surveyed body of literature, what is the fraction of provided replication artifacts for each Evaluation Method?

echo "$ET_THREATS"

echo "Year|Paper ID|Evaluation Method|Replication Package|Threats to Validity" > "$ET_THREATS";
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,4,9,12 | sort -u >> "$ET_THREATS";

ruby mkevaluationperthreats.rb  


#echo "$ET_ARTIFACTS"

#echo "Year|Paper ID|Evaluation Method|Tool Prototype|Input Data|Artifact Evaluation Package" > "$ET_ARTIFACTS";
#tail -n+2 "$REDUCED" | cut -d"|" -f1,2,4,7,8,9 | sort -u >> "$ET_ARTIFACTS";


# Addendum: How many papers reference evaluation guidelines or guidelines for threats to validity

echo "Year|Paper ID|Evaluation Guideline|Threats to Validity Guideline" > "$GUIDELINES"
tail -n+2 "$REDUCED" | cut -d"|" -f1,2,5,10 | awk -F"|" -f guidelines.awk | sort -u >> "$GUIDELINES"

ruby mkguidelines.rb  



# evaluation guidelines pro paper

echo "Compile latex..."

latexmk -pdf summary


